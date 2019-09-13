//
//  RHSocketService.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHChannelService.h"
#import "RHSocketMacros.h"
#import "RHChannelBeats.h"
#import "RHChannelReconnect.h"

@interface RHChannelService ()

@property (nonatomic, strong) RHSocketChannel *channel;
@property (nonatomic, strong) RHChannelConfig *config;
@property (nonatomic, strong) RHChannelReconnect *channelReconnect;

@end

@implementation RHChannelService

#pragma mark - getter & setter

- (RHSocketChannel *)channel
{
    if (nil == _channel) {
        _channel = [[RHSocketChannel alloc] init];
    }
    return _channel;
}

- (RHChannelReconnect *)channelReconnect
{
    if (nil == _channelReconnect) {
        _channelReconnect = [[RHChannelReconnect alloc] init];
    }
    return _channelReconnect;
}

#pragma mark -

- (void)startWithConfig:(void (^)(RHChannelConfig *config))configBlock
{
    //配置channel必要参数
    RHChannelConfig *config = [[RHChannelConfig alloc] init];
    configBlock(config);
    self.config = config;
    [self.config setup:self.channel];
    
    __weak typeof(self) weakSelf = self;
    //重连
    [self.channelReconnect stop];
    self.channelReconnect.connectBlock = ^(RHChannelReconnect *reconnect) {
        //触发重连
        RHSocketLog(@"[Log]: channel reconnect");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.channel openConnection];
    };
    self.channelReconnect.overBlock = ^(RHChannelReconnect *reconnect) {
        RHSocketLog(@"[Log]: channel reconnect over");
    };
    
    [self.channel addDelegate:self];
    [self.channel openConnection];
}

- (void)stopService
{
    [self.channelReconnect stop];
    [self.channel closeConnection];
    [self.channel removeDelegate:self];
    _isRunning = NO;
}

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
    RHSocketLog(@"[Log]: upstream packet %@", [packet stringWithPacket]);
    [self.channel asyncSendPacket:packet];
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    _isRunning = YES;
    
    /** 停止重连 */
    [self.channelReconnect stop];
    /**
     * 开启心跳逻辑
     * 测试场景：连接后直接发起心跳
     * 正常场景：连接后，有用户校验等逻辑，需要在可以通信后开启心跳逻辑
     */
    if (self.config.connectParam.heartbeatEnabled) {
        [self.config.channelBeats start];
    }
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    _isRunning = NO;
    
    /**
     * 开启重连逻辑
     * 断开场景：开始重连
     * 连接失败：开始重连
     */
    if (self.config.connectParam.autoReconnect) {
        [self.channelReconnect start];
    }
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"[Log]: downstream packet %@", [packet stringWithPacket]);
}

@end
