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

#pragma mark - setter & getter

- (RHChannelBeats *)channelBeats
{
    if (nil == _channelBeats) {
        _channelBeats = [[RHChannelBeats alloc] init];
        
        __weak typeof(self) weakSelf = self;
        _channelBeats.beatBlock = ^(RHChannelBeats *channelBeats) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.connectParam.heartbeatEnabled) {
                return;
            }
            [strongSelf asyncSendPacket:strongSelf.heartbeat];
        };
    }
    return _channelBeats;
}

#pragma mark - public function

- (void)startServiceWithHost:(NSString *)host port:(int)port
{
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = port;
    [self startServiceWithConnectParam:connectParam];
}

- (void)startServiceWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (self.isRunning) {
        return;
    }
    
    _connectParam = connectParam;
    
    __weak typeof(self) weakSelf = self;
    [self startWithConfig:^(RHChannelConfig *config) {
        config.connectParam = weakSelf.connectParam;
        config.encoder = weakSelf.encoder;
        config.decoder = weakSelf.decoder;
        config.channelBeats = weakSelf.channelBeats;
        config.delegate = self;
    }];
    
}

- (void)stopService
{
    [super stopService];
    [self.channelBeats stop];
}

#pragma mar - recevie response data

- (void)detectSocketPacketRequest:(NSNotification *)notif
{
    id object = notif.object;
    [self asyncSendPacket:object];
}

#pragma mark -

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    [super channelOpened:channel host:host port:port];
    
    NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(self.isRunning)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(self.isRunning) userInfo:userInfo];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    [super channelClosed:channel error:error];
    
    NSDictionary *userInfo = @{@"isRunning":@(self.isRunning), @"error":error};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketServiceState object:@(self.isRunning) userInfo:userInfo];
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    [super channel:channel received:packet];
    
    NSDictionary *userInfo = @{@"RHSocketPacket":packet};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketResponse object:nil userInfo:userInfo];
}

@end
