//
//  RHSocketChannel+Heartbeat.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"

@interface RHSocketChannel (Heartbeat)

@property (nonatomic, strong) id<RHUpstreamPacket> heartbeat;
@property (nonatomic, strong) NSTimer *heartbeatTimer;

- (void)stopHeartbeatTimer;
- (void)startHeartbeatTimer:(NSTimeInterval)interval;
- (void)heartbeatTimerFunction;
- (void)sendHeartbeat;

@end
