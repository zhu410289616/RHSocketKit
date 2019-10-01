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

#pragma mark - connection

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

#pragma mark - send packet

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
    __weak typeof(self) weakSelf = self;
    [self.upstreamBuffer appendSendPacket:packet encode:^(NSMutableArray *packets) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf isConnected]) {
            return;
        }
        
        NSArray *thePackets = [packets mutableCopy];
        [packets removeAllObjects];
        [strongSelf encodeOfUpstreamPackets:thePackets];
    } overflow:^(id<RHUpstreamBuffer> upstreamBuffer) {
#ifdef DEBUG
        NSAssert(YES, @"[Error]: upstream buffer overflow :(");
#endif
    }];
}

- (void)flushSendPackets
{
    NSArray *thePackets = [self.upstreamBuffer packetsForFlush];
    [self encodeOfUpstreamPackets:thePackets];
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

- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    __weak typeof(self) weakSelf = self;
    [self.downstreamBuffer appendReceiveData:data decode:^NSInteger(NSData *bufferData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return [strongSelf decodeOfDownstreamData:bufferData];
    } overflow:^(id<RHDownstreamBuffer> downstreamBuffer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
#ifdef DEBUG
        NSAssert(YES, @"[Error]: downstream buffer overflow :(");
#endif
        [strongSelf closeConnection];
    }];
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

#pragma mark - encode

/** 发送数据，将编码放入 串行队列 异步处理 */
- (void)encodeOfUpstreamPackets:(NSArray *)bufferPackets
{
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (id<RHUpstreamPacket> packet in bufferPackets) {
            [strongSelf.encoder encode:packet output:strongSelf];
        }
    } async:YES];
}

#pragma mark - RHSocketEncoderOutputProtocol

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
    if (data.length == 0) {
        return;
    }
    [self writeData:data timeout:timeout tag:0];
}

#pragma mark - decode

- (NSInteger)decodeOfDownstreamData:(NSData *)bufferData
{
    //2.3.0版本开始
    if ([_decoder respondsToSelector:@selector(decodeData:output:)]) {
        return [_decoder decodeData:bufferData output:self];
    }
    
    RHSocketPacketResponse *ctx = [[RHSocketPacketResponse alloc] init];
    ctx.object = bufferData;
    return [_decoder decode:ctx output:self];
}

#pragma mark - RHSocketDecoderOutputProtocol

- (void)didDecode:(id<RHDownstreamPacket>)packet
{
    //通知缓存已经解码到数据包，可以用于状态更新等操作
    if ([self.downstreamBuffer respondsToSelector:@selector(decodedPakcet:)]) {
        [self.downstreamBuffer decodedPakcet:packet];
    }
    
    //通知channel已经接收到新数据包
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
