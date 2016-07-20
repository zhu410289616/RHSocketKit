//
//  RHSocketChannelDefault.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"

@interface RHSocketChannelDefault : RHSocketChannel

/**
 *  断开连接后，是否自动重连，默认为no
 */
@property (nonatomic, assign) BOOL autoReconnect;

- (void)stopConnectTimer;
- (void)startConnectTimer:(NSTimeInterval)interval;
- (void)connectTimerFunction;

@end
