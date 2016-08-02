//
//  RHSocketChannelDefault.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"
#import "RHSocketChannel+Heartbeat.h"

@interface RHSocketChannelDefault : RHSocketChannel

/**
 *  心跳定时间隔，默认为20秒
 */
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;

/**
 *  断开连接后，是否自动重连，默认为no
 */
@property (nonatomic, assign) BOOL autoReconnect;

- (void)stopConnectTimer;
- (void)startConnectTimer:(NSTimeInterval)interval;
- (void)connectTimerFunction;

@end
