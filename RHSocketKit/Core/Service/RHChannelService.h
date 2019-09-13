//
//  RHSocketService.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketChannel.h"
#import "RHSocketCodecProtocol.h"
#import "RHChannelConfig.h"

/**
 *  封装好的单例socket服务器工具，需要初始化编码解码器codec
 */
@interface RHChannelService : NSObject <RHSocketChannelDelegate>

/** tcp连接的传输通道 */
@property (nonatomic, strong, readonly) RHSocketChannel *channel;
/** 创建channel，指定必要设置 */
@property (nonatomic, strong, readonly) RHChannelConfig *config;
/** service是否在运行中 */
@property (assign, readonly) BOOL isRunning;

/** 固定心跳包 (设置心跳包，在连接成功后，开启心态定时器) */
//@property (nonatomic, strong) id<RHUpstreamPacket> heartbeat;

//@property (nonatomic, strong, readonly) RHSocketConnectParam *connectParam;

- (void)startWithConfig:(void (^)(RHChannelConfig *config))configBlock;
- (void)stopService;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
