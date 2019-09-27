//
//  RHChannelConfig.h
//  Pods
//
//  Created by zhuruhong on 2019/9/13.
//

#import <Foundation/Foundation.h>
#import "RHSocketChannel.h"
#import "RHChannelBeats.h"

//NS_ASSUME_NONNULL_BEGIN

@interface RHChannelConfig : NSObject

/** 集成统计，只在【DEBUG】环境下生效，可以设置关闭 */
@property (nonatomic, assign) BOOL sendAnalyticsToMe;
/** 拦截写通道的最终数据 */
@property (nonatomic, strong) id<RHSocketInterceptorProtocol> writeInterceptor;
/** 拦截读通道的最初数据 */
@property (nonatomic, strong) id<RHSocketInterceptorProtocol> readInterceptor;
/** 上行数据包缓存 */
@property (nonatomic, strong) id<RHUpstreamBuffer> upstreamBuffer;
/** 下行数据包缓存 */
@property (nonatomic, strong) id<RHDownstreamBuffer> downstreamBuffer;
/** 数据发送时使用的编码器 */
@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
/** 数据接收后处理的解码器 */
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;
/** 心跳逻辑 */
@property (nonatomic, strong) RHChannelBeats *channelBeats;
/** socket连接基本参数 */
@property (nonatomic, strong) RHSocketConnectParam *connectParam;
/** 监听channel事件 */
@property (nonatomic,   weak) id<RHSocketChannelDelegate> delegate;

- (void)setup:(RHSocketChannel *)channel;

@end

//NS_ASSUME_NONNULL_END
