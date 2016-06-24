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

+ (instancetype)sharedInstance;

- (void)startServiceWithHost:(NSString *)host port:(int)port;
- (void)startServiceWithHost:(NSString *)host port:(int)port tlsSettings:(NSDictionary *)tlsSettings;
- (void)stopService;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
