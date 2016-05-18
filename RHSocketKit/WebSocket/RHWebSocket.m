//
//  RHWebSocket.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/18.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHWebSocket.h"
#import "RHSocketConnection.h"
#import "RHSocketPacketContext.h"
#import "RHSocketUtils.h"

@interface RHWebSocket () <RHSocketConnectionDelegate>

@property (nonatomic, strong) RHSocketConnection *connection;
@property (nonatomic, strong) NSMutableData *receiveDataBuffer;
@property (nonatomic, strong) RHSocketPacketResponse *downstreamContext;

@end

@implementation RHWebSocket

- (instancetype)init
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
    }
    return self;
}

- (instancetype)initWithConfig:(RHWebSocketConfig *)config
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
        _config = config;
    }
    return self;
}

- (void)openConnection
{
    @synchronized(self) {
        [self closeConnection];
        _connection = [[RHSocketConnection alloc] init];
        _connection.delegate = self;
        [_connection connectWithHost:_config.host port:_config.port];
    }//@synchronized
}

- (void)closeConnection
{
    @synchronized(self) {
        if (_connection) {
            _connection.delegate = nil;
            [_connection disconnect];
            _connection = nil;
        }
    }//synchronized
}

- (BOOL)isConnected
{
    return [_connection isConnected];
}

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
//    if (nil == _encoder) {
//        RHSocketLog(@"RHSocket Encoder should not be nil ...");
//        return;
//    }
//    [_encoder encode:packet output:self];
}

#pragma mark - RHSocketConnectionDelegate

- (void)didDisconnectWithError:(NSError *)error
{
    [_delegate socket:self didDisconnectWithError:error];
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
    [_delegate socket:self didConnectToHost:host port:port];
    
    _status = RHWebSocketStatusHandshake;
    [_connection writeData:[_config dataWithHandshake] timeout:_config.timeout tag:0];
}

- (void)didReceiveData:(NSData *)data tag:(long)tag
{
    if (data.length < 1) {
        return;
    }
    
    RHSocketLog(@"didReceiveData[%ld]: %@", tag, data);
    
    @synchronized (self) {
        [_receiveDataBuffer appendData:data];
        
        //判断是否在握手阶段
        if (_status == RHWebSocketStatusHandshake) {
            NSRange range = NSMakeRange(0, _receiveDataBuffer.length);
            NSRange resultRange = [_receiveDataBuffer rangeOfData:[RHSocketUtils CRLFData] options:NSDataSearchBackwards range:range];
            if (resultRange.location == NSNotFound || resultRange.length == 0) {
                return;
            }
            //
            NSRange handshakeRange = NSMakeRange(0, resultRange.location + 2);//CRLFData占2个字节
            NSData *handshakeData = [_receiveDataBuffer subdataWithRange:handshakeRange];
            RHSocketLog(@"handshake: %@", [[NSString alloc] initWithData:handshakeData encoding:NSUTF8StringEncoding]);
            [_delegate socket:self didHandshakeFinished:_config];
            
            //
            NSUInteger remainLength = _receiveDataBuffer.length - handshakeData.length;
            NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(handshakeData.length, remainLength)];
            [_receiveDataBuffer setData:remainData];
            _status = RHWebSocketStatusActive;
        }
        
//        if (nil == _decoder) {
//            RHSocketLog(@"RHSocket Decoder should not be nil ...");
//            return;
//        }
//        
//        //
//        _downstreamContext.object = _receiveDataBuffer;
//        NSInteger decodedLength = [_decoder decode:_downstreamContext output:self];
//        
//        if (decodedLength < 0) {
//            [self closeConnection];
//            return;
//        }//if
//        
//        if (decodedLength > 0) {
//            NSUInteger remainLength = _receiveDataBuffer.length - decodedLength;
//            NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(decodedLength, remainLength)];
//            [_receiveDataBuffer setData:remainData];
//        }//if
    }//@synchronized
}

@end
