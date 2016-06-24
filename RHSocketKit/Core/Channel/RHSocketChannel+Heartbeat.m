//
//  RHSocketChannel+Heartbeat.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel+Heartbeat.h"

@implementation RHSocketChannel (Heartbeat)

@dynamic heartbeat;
@dynamic heartbeatTimer;

- (void)stopHeartbeatTimer
{
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
}

- (void)startHeartbeatTimer:(NSTimeInterval)interval
{
    NSTimeInterval minInterval = MIN(5, interval);
    [self stopHeartbeatTimer];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:minInterval target:self selector:@selector(heartbeatTimerFunction) userInfo:nil repeats:YES];
}

- (void)heartbeatTimerFunction
{
    [self sendHeartbeat];
}

- (void)sendHeartbeat
{
    [self asyncSendPacket:self.heartbeat];
}

@end
