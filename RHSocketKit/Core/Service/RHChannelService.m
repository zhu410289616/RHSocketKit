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
@property (nonatomic, strong) RHChannelBeats *channelBeats;
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

- (RHChannelBeats *)channelBeats
{
    if (nil == _channelBeats) {
        _channelBeats = [[RHChannelBeats alloc] init];
    }
    return _channelBeats;
}

- (RHChannelReconnect *)channelReconnect
{
    if (nil == _channelReconnect) {
        _channelReconnect = [[RHChannelReconnect alloc] init];
    }
    return _channelReconnect;
}

#pragma mark -

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
    
    __weak typeof(self) weakSelf = self;
    
    //重连
    [self.channelReconnect stop];
    self.channelReconnect.connectBlock = ^(RHChannelReconnect *reconnect) {
        //触发重连
        RHSocketLog(@"[Log]: channel reconnect");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf openConnection];
    };
    self.channelReconnect.overBlock = ^(RHChannelReconnect *reconnect) {
        RHSocketLog(@"[Log]: channel reconnect over");
    };
    
    //心跳
    [self.channelBeats stop];
    self.channelBeats.interval = connectParam.heartbeatInterval;
    self.channelBeats.beatBlock = ^(RHChannelBeats *channelBeats) {
        //发送心跳包
        RHSocketLog(@"[Log]: channel beats");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf asyncSendPacket:strongSelf.heartbeat];
    };
    self.channelBeats.overBlock = ^(RHChannelBeats *channelBeats) {
        RHSocketLog(@"[Log]: channel beats over");
    };
    
    _connectParam = connectParam;
    [self openConnection];
}

- (void)stopService
{
    _connectParam.heartbeatEnabled = NO;
    _connectParam.autoReconnect = NO;
    _isRunning = NO;
    [self closeConnection];
}

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
{
    RHSocketLog(@"[Log]: upstream packet %@", [packet stringWithPacket]);
    [self.channel asyncSendPacket:packet];
}

#pragma mark -
#pragma mark RHSocketConnection method

- (void)openConnection
{
    [self closeConnection];
    
    self.channel.connectParam = _connectParam;
    [self.channel addDelegate:self];
    self.channel.encoder = _encoder;
    self.channel.decoder = _decoder;
    [self.channel openConnection];
}

- (void)closeConnection
{
    if (self.channel) {
        [self.channel closeConnection];
        [self.channel removeDelegate:self];
    }
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
    if (self.connectParam.heartbeatEnabled) {
        [self.channelBeats start];
    }
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    _isRunning = NO;
    
    /** 停止心跳 */
    [self.channelBeats stop];
    /**
     * 开启重连逻辑
     * 断开场景：开始重连
     * 连接失败：开始重连
     */
    if (self.connectParam.autoReconnect) {
        [self.channelReconnect start];
    }
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"[Log]: downstream packet %@", [packet stringWithPacket]);
}

@end
