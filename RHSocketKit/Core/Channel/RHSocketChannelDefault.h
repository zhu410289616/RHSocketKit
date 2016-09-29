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

- (void)stopConnectTimer;
- (void)startConnectTimer:(NSTimeInterval)interval;
- (void)connectTimerFunction;

@end
