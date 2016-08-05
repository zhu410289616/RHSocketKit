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
    return [self initWithHost:nil port:0];
}

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super initWithHost:host port:port]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
    }
    return self;
}

- (void)openConnection
{
    if ([self isConnected]) {
        return;
    }
    [self closeConnection];
    [self connectWithHost:self.host port:self.port];
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
    
    [self dispatchOnSocketQueue:^{
        [_encoder encode:packet output:self];
    } async:YES];
    
}

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

#pragma mark - RHSocketConnectionDelegate

- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate channelClosed:self error:err];
    });
}

- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate channelOpened:self host:host port:port];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate channel:self received:packet];
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
