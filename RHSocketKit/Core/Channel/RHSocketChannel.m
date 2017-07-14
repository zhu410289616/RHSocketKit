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

@interface RHSocketChannel () <RHSocketEncoderOutputProtocol, RHSocketDecoderOutputProtocol>

@property (nonatomic, strong, readonly) NSMutableData *receiveDataBuffer;
@property (nonatomic, strong, readonly) RHSocketPacketResponse *downstreamContext;

@end

@implementation RHSocketChannel

- (instancetype)init
{
    return [self initWithConnectParam:nil];
}

- (instancetype)initWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (self = [super initWithConnectParam:connectParam]) {
        _delegateMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
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
    if (nil == packet) {
        RHSocketLog(@"Warning: RHSocket asyncSendPacket packet is nil ...");
        return;
    };
    
    if (nil == _encoder) {
        RHSocketLog(@"RHSocket Encoder should not be nil ...");
        return;
    }
    
    //发送数据，将编码放入 串行队列 异步处理
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        [weakSelf.encoder encode:packet output:weakSelf];
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

- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    if (data.length == 0) {
        return;
    }
    
    if (nil == _decoder) {
        RHSocketLog(@"RHSocket Decoder should not be nil ...");
        return;
    }
    
    @synchronized(self) {
        [_receiveDataBuffer appendData:data];
        
        _downstreamContext.object = _receiveDataBuffer;
        NSInteger decodedLength = [_decoder decode:_downstreamContext output:self];
        
        if (decodedLength < 0) {
            [RHSocketException raiseWithReason:@"Decode Failed ..."];
            [self closeConnection];
            return;
        }//if
        
        if (decodedLength > 0) {
            NSUInteger remainLength = _receiveDataBuffer.length - decodedLength;
            NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(decodedLength, remainLength)];
            [_receiveDataBuffer setData:remainData];
        }//if
    }//@synchronized
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

#pragma mark - RHSocketEncoderOutputProtocol

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
    if (data.length == 0) {
        return;
    }
    [self writeData:data timeout:timeout tag:0];
}

#pragma mark - RHSocketDecoderOutputProtocol

- (void)didDecode:(id<RHDownstreamPacket>)packet
{
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
