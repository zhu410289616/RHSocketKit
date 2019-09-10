//
//  RHChannelReconnect.h
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@class RHChannelReconnect;

typedef void(^RHChannelReconnectConnectBlock)(RHChannelReconnect *reconnect);
typedef void(^RHChannelReconnectOverBlock)(RHChannelReconnect *reconnect);

/** channel重连逻辑 */
@interface RHChannelReconnect : NSObject

@property (nonatomic, copy) RHChannelReconnectConnectBlock connectBlock;
@property (nonatomic, copy) RHChannelReconnectOverBlock overBlock;
/** 重连间隔 默认为15秒 */
@property (nonatomic, assign) double interval;
/** 最大重连次数 默认100次 */
@property (nonatomic, assign) NSInteger maxConnectCount;
/** 是否结束 */
@property (nonatomic, assign) BOOL isOver;

- (void)start;
- (void)stop;

@end

//NS_ASSUME_NONNULL_END
