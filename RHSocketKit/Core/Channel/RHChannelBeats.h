//
//  RHChannelBeats.h
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

//NS_ASSUME_NONNULL_BEGIN

@class RHChannelBeats;

typedef void(^RHChannelBeatsBeat)(RHChannelBeats *channelBeats);
typedef void(^RHChannelBeatsOver)(RHChannelBeats *channelBeats);
typedef id<RHUpstreamPacket>(^RHChannelHeartbeat)(void);

@interface RHChannelBeats : NSObject

/** 心跳跳动block */
@property (nonatomic, copy) RHChannelBeatsBeat beatBlock;
/** 心跳结束block */
@property (nonatomic, copy) RHChannelBeatsOver overBlock;
/** 心跳数据包block */
@property (nonatomic, copy) RHChannelHeartbeat heartbeatBlock;
/** 心跳间隔 默认20秒 */
@property (nonatomic, assign) double interval;
/** 是否结束 */
@property (nonatomic, assign) BOOL isOver;

- (void)start;
- (void)stop;

@end

//NS_ASSUME_NONNULL_END
