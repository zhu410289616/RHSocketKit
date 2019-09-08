//
//  RHSocketHeartbeat.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RHSocketHeartbeat;

typedef void(^RHSocketHeartbeatBeat)(RHSocketHeartbeat *heartbeat);
typedef void(^RHSocketHeartbeatOver)(RHSocketHeartbeat *heartbeat);

@interface RHSocketHeartbeat : NSObject

@property (nonatomic, copy) RHSocketHeartbeatBeat beatBlock;
@property (nonatomic, copy) RHSocketHeartbeatOver overBlock;
/** 心跳间隔 */
@property (nonatomic, assign) double interval;
/** 是否心跳结束 */
@property (nonatomic, assign) BOOL isOver;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
