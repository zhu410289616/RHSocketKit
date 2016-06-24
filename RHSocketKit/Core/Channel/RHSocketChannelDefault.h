//
//  RHSocketChannelDefault.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"

@interface RHSocketChannelDefault : RHSocketChannel

@property (nonatomic, strong, readonly) NSTimer *connectTimer;

/**
 *  断开连接后，是否自动重连，默认为no
 */
@property (nonatomic, assign) BOOL autoReconnect;

/**
 *  开始自动重连后，尝试重连次数，默认为500次
 */
@property (nonatomic, assign) NSInteger connectCount;

/**
 *  开始自动重连后，首次重连时间间隔，默认为5秒，后面每常识重连10次增加5秒
 */
@property (nonatomic, assign) NSTimeInterval connectTimerInterval;

@end
