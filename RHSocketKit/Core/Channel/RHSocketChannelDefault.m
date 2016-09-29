//
//  RHSocketChannelDefault.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannelDefault.h"

#define kConnectMaxCount            1000    //tcp断开重连次数
#define kConnectTimerInterval       5       //单位秒s

@interface RHSocketChannelDefault ()

/**
 *  自动重连使用的计时器
 */
@property (nonatomic, strong, readonly) NSTimer *connectTimer;

/**
 *  开始自动重连后，尝试重连次数，默认为500次
 */
@property (nonatomic, assign, readonly) NSInteger connectCount;

/**
 *  开始自动重连后，首次重连时间间隔，默认为5秒，后面每常识重连10次增加5秒
 */
@property (nonatomic, assign, readonly) NSTimeInterval connectTimerInterval;

@end

@implementation RHSocketChannelDefault

- (instancetype)initWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (self = [super initWithConnectParam:connectParam]) {
        //初始化自动重连参数
        _connectCount = 0;
        _connectTimerInterval = kConnectTimerInterval;
    }
    return self;
}

- (void)closeConnection
{
    [super closeConnection];
    
    [self stopConnectTimer];
    [self stopHeartbeatTimer];
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
    NSTimeInterval minInterval = MAX(5, interval);
    RHSocketLog(@"startConnectTimer minInterval: %f", minInterval);
    
    [self stopConnectTimer];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:minInterval target:self selector:@selector(connectTimerFunction) userInfo:nil repeats:NO];
}

- (void)connectTimerFunction
{
    if (!self.connectParam.autoReconnect) {
        [self stopConnectTimer];
        return;
    }
    
    //重连次数超过最大尝试次数，停止
    if (_connectCount > kConnectMaxCount) {
        [self stopConnectTimer];
        return;
    }
    
    _connectCount++;
    
    //重连时间策略
    if (_connectCount % 10 == 0) {
        _connectTimerInterval += kConnectTimerInterval;
        [self startConnectTimer:_connectTimerInterval];
    }
    
    if ([self isConnected]) {
        return;
    }
    [self openConnection];
}

- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    [super didDisconnect:con withError:err];
    
    if (self.connectParam.autoReconnect) {
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _connectTimerInterval), dispatch_get_main_queue(), ^{
            [weakSelf startConnectTimer:weakSelf.connectTimerInterval];
        });
    }
}

- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    //连接成功后，重置自动重连参数
    _connectCount = 0;
    _connectTimerInterval = kConnectTimerInterval;
    
    if (self.connectParam.heartbeatEnabled) {
        __weak __typeof(self) weakSelf = self;
        //连接方法都在 串行队列 异步执行，定时器在主线程中执行
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopConnectTimer];
            //连接成功后，开启心跳定时器 [设置了心跳包 channel.heartbeat = req]
            [weakSelf startHeartbeatTimer:weakSelf.connectParam.heartbeatInterval];
        });
    }
    
    [super didConnect:con toHost:host port:port];
}

@end
