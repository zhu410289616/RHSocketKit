//
//  RHSocketChannelDefault.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannelDefault.h"

@implementation RHSocketChannelDefault

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super initWithHost:host port:port]) {
        _autoReconnect = NO;
        _connectCount = 500;
        _connectTimerInterval = 5;
    }
    return self;
}

- (void)stopConnectTimer
{
    if (_connectTimer) {
        [_connectTimer invalidate];
        _connectTimer = nil;
    }
}

- (void)startConnectTimer:(NSTimeInterval)interval
{
    NSTimeInterval minInterval = MIN(5, interval);
    [self stopConnectTimer];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:minInterval target:self selector:@selector(connectTimerFunction) userInfo:nil repeats:YES];
}

- (void)connectTimerFunction
{
    if (!_autoReconnect) {
        [self stopConnectTimer];
        return;
    }
    
    //重连次数超过最大尝试次数，停止
    if (_connectCount > 500) {
        [self stopConnectTimer];
        return;
    }
    
    _connectCount++;
    
    //重连时间策略
    if (_connectCount % 10 == 0) {
        _connectTimerInterval += 5;
        [self startConnectTimer:_connectTimerInterval];
    }
    
    [self openConnection];
}

- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    [super didDisconnect:con withError:err];
    
    if (_autoReconnect) {
        [self startConnectTimer:_connectTimerInterval];
    }
}

- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    _connectCount = 500;
    _connectTimerInterval = 5;
    [self stopConnectTimer];
    
    [super didConnect:con toHost:host port:port];
}

@end
