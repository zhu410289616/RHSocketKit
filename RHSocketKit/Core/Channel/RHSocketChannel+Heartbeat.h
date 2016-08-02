//
//  RHSocketChannel+Heartbeat.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"

@interface RHSocketChannel (Heartbeat)

/**
 *  固定心跳包 (设置心跳包，在连接成功后，开启心态定时器)
 */
@property (nonatomic, strong) id<RHUpstreamPacket> heartbeat;

/**
 *  心跳定时器，这里使用的是NSTimer，在断开连接后，需要手动停止心跳定时器(使用MSWeakTimer更好)
 */
@property (nonatomic, strong) NSTimer *heartbeatTimer;

- (void)stopHeartbeatTimer;
- (void)startHeartbeatTimer:(NSTimeInterval)interval;
- (void)heartbeatTimerFunction;
- (void)sendHeartbeat;

@end
