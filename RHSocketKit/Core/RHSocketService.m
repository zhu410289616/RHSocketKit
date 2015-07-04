//
//  RHSocketService.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketService.h"
#import "RHSocketConnection.h"
#import "RHSocketDelimiterEncoder.h"
#import "RHSocketDelimiterDecoder.h"

NSString *const kNotificationSocketServiceState = @"kNotificationSocketServiceState";
NSString *const kNotificationSocketPacketRequest = @"kNotificationSocketPacketRequest";
NSString *const kNotificationSocketPacketResponse = @"kNotificationSocketPacketResponse";

@interface RHSocketService () <RHSocketConnectionDelegate>
{
    RHSocketConnection *_connection;
}

@end

@implementation RHSocketService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketPacketRequest:) name:kNotificationSocketPacketRequest object:nil];
        _encoder = [[RHSocketDelimiterEncoder alloc] init];
        _decoder = [[RHSocketDelimiterDecoder alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startServiceWithHost:(NSString *)host port:(int)port
{
    NSAssert(_encoder, @"error, _encoder is nil...");
    NSAssert(_decoder, @"error, _decoder is nil...");
    NSAssert(host.length > 0, @"error, host is nil...");
    
    if (_isRunning) {
        return;
    }
    
    _serverHost = host;
    _serverPort = port;
    
    [self openConnection];
}

- (void)stopService
{
    _isRunning = NO;
    [self closeConnection];
}

- (void)asyncSendPacket:(id<RHSocketPacketContent>)packet
{
    if (!_isRunning) {
        NSDictionary *userInfo = @{@"msg":@"Send packet error. Service is stop!"};
        NSError *error = [NSError errorWithDomain:@"RHSocketService" code:1 userInfo:userInfo];
        [self didDisconnectWithError:error];
        return;
    }
    [_encoder encodePacket:packet encoderOutput:self];
}

#pragma mar -
#pragma mark recevie response data

- (void)detectSocketPacketRequest:(NSNotification *)notif
{
    id object = notif.object;
    [self asyncSendPacket:object];
}

#pragma mark -
#pragma mark RHSocketConnection method

- (void)openConnection
{
    [self closeConnection];
    _connection = [[RHSocketConnection alloc] init];
    _connection.delegate = self;
    [_connection connectWithHost:_serverHost port:_serverPort];
}

- (void)closeConnection
{
    if (_connection) {
        _connection.delegate = nil;
        [_connection disconnect];
        _connection = nil;
    }
}

#pragma mark -
#pragma mark RHSocketConnectionDelegate method

- (void)didDisconnectWithError:(NSError *)error
{
    RHSocketLog(@"didDisconnectWithError: %@", error);
    _isRunning = NO;
    NSDictionary *userInfo = @{@"isRunning":@(_isRunning), @"error":error};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(_isRunning) userInfo:userInfo];
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
    _isRunning = YES;
    NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(_isRunning) userInfo:userInfo];
}

- (void)didReceiveData:(NSData *)data tag:(long)tag
{
    NSUInteger remainDataLen = [_decoder decodeData:data decoderOutput:self tag:tag];
    if (remainDataLen > 0) {
        [_connection readDataWithTimeout:-1 tag:tag];
    } else {
        [_connection readDataWithTimeout:-1 tag:0];
    }
}

#pragma mark -
#pragma mark RHSocketEncoderOutputDelegate method

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout tag:(NSInteger)tag
{
    [_connection writeData:data timeout:timeout tag:tag];
}

#pragma mark -
#pragma mark RHSocketDecoderOutputDelegate method

- (void)didDecode:(id<RHSocketPacketContent>)packet tag:(NSInteger)tag
{
    NSDictionary *userInfo = @{@"RHSocketPacketBody":packet, @"tag":@(tag)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketResponse object:nil userInfo:userInfo];
}

@end
