//
//  RHSocketChannel.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/15.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"
#import "RHSocketException.h"
#import "RHSocketPacketContext.h"
#import "RHSocketUtils.h"
#import "RHSocketMacros.h"

@interface RHSocketChannel ()

@end

@implementation RHSocketChannel

#ifdef DEBUG
- (void)dealloc
{
    RHSocketLog(@"[Log]: %@ dealloc", self.class);
}
#endif

- (instancetype)init
{
    return [self initWithConnectParam:nil];
}

- (instancetype)initWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (self = [super initWithConnectParam:connectParam]) {
        _delegateMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (void)setDelegate:(id<RHSocketChannelDelegate>)delegate
{
    _delegate = delegate;
    [self addDelegate:delegate];
}

- (void)addDelegate:(id<RHSocketChannelDelegate>)delegate
{
    NSString *key = NSStringFromClass([delegate class]);
    [self.delegateMap setObject:delegate forKey:key];
}

- (void)removeDelegate:(id<RHSocketChannelDelegate>)delegate
{
    NSString *key = NSStringFromClass([delegate class]);
    [self.delegateMap removeObjectForKey:key];
}

- (void)openConnection
{
    if ([self isConnected]) {
        return;
    }
    [self closeConnection];
    [self connectWithParam:self.connectParam];
}

- (void)closeConnection
{
    [self disconnect];
}

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
    [self.upstreamBuffer appendSendPacket:packet];
}

- (void)flushSendPackets
{
    NSArray *thePackets = [self.upstreamBuffer packetsForFlush];
    
    //发送数据，将编码放入 串行队列 异步处理
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (id<RHUpstreamPacket> packet in thePackets) {
            [strongSelf.encoder encode:packet output:strongSelf];
        }
    } async:YES];
}

#pragma mark - RHSocketConnectionDelegate

- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    //回调上层处理时，切换回主线程 [发送数据，接收数据，解码数据 都是在socket线程中处理]
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *objectEnumerator = [self.delegateMap objectEnumerator];
        id<RHSocketChannelDelegate> delegate = nil;
        while (delegate = [objectEnumerator nextObject]) {
            [delegate channelClosed:self error:err];
        }
    });
}

- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    //回调上层处理时，切换回主线程 [发送数据，接收数据，解码数据 都是在socket线程中处理]
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *objectEnumerator = [self.delegateMap objectEnumerator];
        id<RHSocketChannelDelegate> delegate = nil;
        while (delegate = [objectEnumerator nextObject]) {
            [delegate channelOpened:self host:host port:port];
        }
    });
    
    //有些应用是在连接服务器后直接读取一个返回值，这里需要做一次读取操作
    [self readDataWithTimeout:-1 tag:0];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    NSData *theData = data;
    if ([self.writeInterceptor respondsToSelector:@selector(interceptor:error:)]) {
        theData = [self.writeInterceptor interceptor:theData error:nil];
    }
    [super writeData:theData timeout:timeout tag:tag];
}

- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    NSData *theData = data;
    if ([self.readInterceptor respondsToSelector:@selector(interceptor:error:)]) {
        theData = [self.readInterceptor interceptor:theData error:nil];
    }
    [self.downstreamBuffer appendReceiveData:theData];
}

- (void)didReceived:(id<RHSocketConnectionDelegate>)con withPacket:(id<RHDownstreamPacket>)packet
{
    //回调上层处理时，切换回主线程 [发送数据，接收数据，解码数据 都是在socket线程中处理]
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *objectEnumerator = [self.delegateMap objectEnumerator];
        id<RHSocketChannelDelegate> delegate = nil;
        while (delegate = [objectEnumerator nextObject]) {
            [delegate channel:self received:packet];
        }
    });
}

#pragma mark - RHUpstreamBufferDelegate

- (void)packetWillEncode:(NSMutableArray *)packets
{
    if (![self isConnected]) {
        return;
    }
    
    NSArray *thePackets = [packets mutableCopy];
    [packets removeAllObjects];
    
    //发送数据，将编码放入 串行队列 异步处理
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (id<RHUpstreamPacket> packet in thePackets) {
            [strongSelf.encoder encode:packet output:strongSelf];
        }
    } async:YES];
}

- (void)upstreamBufferOverflow:(id<RHUpstreamBuffer>)upstreamBuffer
{
#ifdef DEBUG
    NSAssert(YES, @"[Error]: upstream buffer overflow :(");
#endif
}

#pragma mark - RHSocketEncoderOutputProtocol

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
    if (data.length == 0) {
        return;
    }
    [self writeData:data timeout:timeout tag:0];
}

#pragma mark - RHDownstreamBufferDelegate

/**
 * 解码前数据缓存块
 * bufferData：待解码数据块
 * return：已经解码数据块大小
 */
- (NSInteger)dataWillDecode:(NSData *)bufferData
{
    //2.3.0版本开始
    if ([_decoder respondsToSelector:@selector(decodeData:output:)]) {
        return [_decoder decodeData:bufferData output:self];
    }
    
    RHSocketPacketResponse *ctx = [[RHSocketPacketResponse alloc] init];
    ctx.object = bufferData;
    return [_decoder decode:ctx output:self];
}

/**
 * 数据未被正常解码消费，缓冲区溢出
 * bufferData：当前缓冲区数据
 */
- (void)downstreamBufferOverflow:(NSData *)bufferData
{
#ifdef DEBUG
    NSAssert(YES, @"[Error]: downstream buffer overflow :(");
#endif
    [self closeConnection];
}

/**
 * 解码后剩余数据缓存块
 * bufferData：剩余数据块
 * decodedSize：本次解码数据块大小
 */
- (void)dataDidDecode:(NSInteger)remainDataSize
{
    RHSocketLog(@"[Log]: remain data size: %ld", remainDataSize);
}

#pragma mark - RHSocketDecoderOutputProtocol

- (void)didDecode:(id<RHDownstreamPacket>)packet
{
    [self.downstreamBuffer decodedPakcet:packet];
    [self didReceived:self withPacket:packet];
}

@end

@implementation RHSocketChannel (WriteInt)

- (void)writeInt8:(int8_t)param
{
    NSData *data = [RHSocketUtils byteFromInt8:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt16:(int16_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt16:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt32:(int32_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt32:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt64:(int64_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt64:param];
    [self writeData:data timeout:-1 tag:0];
}

@end
