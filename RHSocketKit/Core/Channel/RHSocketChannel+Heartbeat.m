//
//  RHSocketChannel+Heartbeat.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel+Heartbeat.h"
#import <objc/runtime.h>

static char rh_heartbeatKey;
static char rh_heartbeatTimerKey;

@implementation RHSocketChannel (Heartbeat)

- (id<RHUpstreamPacket>)heartbeat
{
    return objc_getAssociatedObject(self, &rh_heartbeatKey);
}

- (void)setHeartbeat:(id<RHUpstreamPacket>)heartbeat
{
    objc_setAssociatedObject(self, &rh_heartbeatKey, heartbeat, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)heartbeatTimer
{
    return objc_getAssociatedObject(self, &rh_heartbeatTimerKey);
}

- (void)setHeartbeatTimer:(NSTimer *)heartbeatTimer
{
    objc_setAssociatedObject(self, &rh_heartbeatTimerKey, heartbeatTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)stopHeartbeatTimer
{
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
}

- (void)startHeartbeatTimer:(NSTimeInterval)interval
{
    NSTimeInterval minInterval = MAX(5, interval);
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
