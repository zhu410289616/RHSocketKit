//
//  RHSocketService.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketChannelDefault.h"
#import "RHSocketCodecProtocol.h"

extern NSString *const kNotificationSocketServiceState;
extern NSString *const kNotificationSocketPacketRequest;
extern NSString *const kNotificationSocketPacketResponse;

/**
 *  封装好的单例socket服务器工具，需要初始化编码解码器codec
 */
@interface RHSocketService : NSObject <RHSocketChannelDelegate>

/**
 *  tcp连接的传输通道
 */
@property (nonatomic, strong, readonly) RHSocketChannelDefault *channel;

/**
 *  数据发送时使用的编码器
 */
@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;

/**
 *  数据接收后处理的解码器
 */
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;

/**
 *  service是否在运行中
 */
@property (assign, readonly) BOOL isRunning;

/**
 *  固定心跳包 (设置心跳包，在连接成功后，开启心态定时器)
 */
@property (nonatomic, strong) id<RHUpstreamPacket> heartbeat;

@property (nonatomic, strong, readonly) RHSocketConnectParam *connectParam;

+ (instancetype)sharedInstance;

- (void)startServiceWithHost:(NSString *)host port:(int)port;
- (void)startServiceWithConnectParam:(RHSocketConnectParam *)connectParam;
- (void)stopService;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
