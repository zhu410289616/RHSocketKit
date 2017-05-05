//
//  RHSocketService.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketService.h"

NSString *const kNotificationSocketServiceState = @"kNotificationSocketServiceState";
NSString *const kNotificationSocketPacketRequest = @"kNotificationSocketPacketRequest";
NSString *const kNotificationSocketPacketResponse = @"kNotificationSocketPacketResponse";

@interface RHSocketService ()

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
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startServiceWithHost:(NSString *)host port:(int)port
{
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = port;
    [self startServiceWithConnectParam:connectParam];
}

- (void)startServiceWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (_isRunning) {
        return;
    }
    
    _connectParam = connectParam;
    [self openConnection];
}

- (void)stopService
{
    _connectParam.autoReconnect = NO;
    _isRunning = NO;
    [self closeConnection];
}

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
    if (!_isRunning) {
        NSDictionary *userInfo = @{@"msg":@"Send packet error. Service is stop!"};
        NSError *error = [NSError errorWithDomain:@"RHSocketService" code:1 userInfo:userInfo];
        [self channelClosed:_channel error:error];
        return;
    }
    [_channel asyncSendPacket:packet];
}

#pragma mar - recevie response data

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
    
    _channel = [[RHSocketChannelDefault alloc] initWithConnectParam:_connectParam];
    [_channel addDelegate:self];
    _channel.encoder = _encoder;
    _channel.decoder = _decoder;
    _channel.heartbeat = _heartbeat;
    [_channel openConnection];
}

- (void)closeConnection
{
    if (_channel) {
        [_channel closeConnection];
        [_channel removeDelegate:self];
        _channel = nil;
    }
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    _isRunning = YES;
    NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(_isRunning) userInfo:userInfo];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    _isRunning = NO;
    NSDictionary *userInfo = @{@"isRunning":@(_isRunning), @"error":error};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(_isRunning) userInfo:userInfo];
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    NSDictionary *userInfo = @{@"RHSocketPacket":packet};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketResponse object:nil userInfo:userInfo];
}

@end
