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

@property (nonatomic, strong, readonly) RHSocketChannelDefault *channel;
@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;
@property (assign, readonly) BOOL isRunning;

/**
 *  固定心跳包 (设置心跳包，在连接成功后，开启心态定时器)
 */
@property (nonatomic, strong) id<RHUpstreamPacket> heartbeat;

/**
 *  断开连接后，是否自动重连，默认为no
 */
@property (nonatomic, assign) BOOL autoReconnect;

+ (instancetype)sharedInstance;

- (void)startServiceWithHost:(NSString *)host port:(int)port;
- (void)startServiceWithHost:(NSString *)host port:(int)port tlsSettings:(NSDictionary *)tlsSettings;
- (void)stopService;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
