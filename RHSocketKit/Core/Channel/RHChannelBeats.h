//
//  RHChannelBeats.h
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@class RHChannelBeats;

typedef void(^RHChannelBeatsBeat)(RHChannelBeats *channelBeats);
typedef void(^RHChannelBeatsOver)(RHChannelBeats *channelBeats);

@interface RHChannelBeats : NSObject

@property (nonatomic, copy) RHChannelBeatsBeat beatBlock;
@property (nonatomic, copy) RHChannelBeatsOver overBlock;
/** 心跳间隔 默认20秒 */
@property (nonatomic, assign) double interval;
/** 是否结束 */
@property (nonatomic, assign) BOOL isOver;

- (void)start;
- (void)stop;

@end

//NS_ASSUME_NONNULL_END
