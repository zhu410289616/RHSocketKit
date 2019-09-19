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

/** 开启channel服务 */
- (void)startWithConfig:(void (^)(RHChannelConfig *config))configBlock;
/** 停止channel服务 */
- (void)stopService;
/** 异步发生数据包 */
- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
