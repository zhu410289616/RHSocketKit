//
//  RHSocketChannel.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/15.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"
#import "RHSocketConnection.h"
#import "RHSocketException.h"

@interface RHSocketChannel () <RHSocketConnectionDelegate, RHSocketEncoderOutputProtocol, RHSocketDecoderOutputProtocol>
{
    RHSocketConnection *_connection;
    //
    NSMutableData *_receiveDataBuffer;
}

@end

@implementation RHSocketChannel

- (instancetype)init
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _host = host;
        _port = port;
    }
    return self;
}

- (void)openConnection
{
    if (nil == _codec) {
        [RHSocketException raiseWithReason:@"RHSocket Codec should not be nil ..."];
        return;
    }
    
    @synchronized(self) {
        [self closeConnection];
        _connection = [[RHSocketConnection alloc] init];
        _connection.delegate = self;
        [_connection connectWithHost:_host port:_port];
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
    [_codec encode:packet output:self];
}

#pragma mark RHSocketConnectionDelegate method

- (void)didDisconnectWithError:(NSError *)error
{
    [_delegate channelClosed:self error:error];
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
    [_delegate channelOpened:self host:host port:port];
}

- (void)didReceiveData:(NSData *)data tag:(long)tag
{
    if (data.length < 1) {
        return;
    }
    
    @synchronized(self) {
        [_receiveDataBuffer appendData:data];
        NSInteger decodedLength = [_codec decode:_receiveDataBuffer output:self];
        
        if (decodedLength < 0) {
            [RHSocketException raiseWithReason:@"Decode Failed ..."];
            [self closeConnection];
            return;
        }//if
        
        if (decodedLength > 0) {
            NSUInteger remainLength = _receiveDataBuffer.length - decodedLength;
            NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(0, remainLength)];
            [_receiveDataBuffer setData:remainData];
        }//if
    }//@synchronized
}

#pragma mark - RHSocketEncoderOutputProtocol

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
    if (data.length < 1) {
        return;
    }
    [_connection writeData:data timeout:timeout tag:0];
}

#pragma mark - RHSocketDecoderOutputProtocol

- (void)didDecode:(id<RHDownstreamPacket>)packet
{
    [_delegate channel:self received:packet];
}

@end
