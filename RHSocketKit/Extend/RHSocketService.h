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

extern NSString *const kNotificationSocketServiceState;
extern NSString *const kNotificationSocketPacketRequest;
extern NSString *const kNotificationSocketPacketResponse;

@interface RHSocketService : NSObject <RHSocketChannelDelegate>

@property (nonatomic, strong, readonly) RHSocketChannel *channel;
@property (nonatomic, strong) id<RHSocketCodecProtocol> codec;
@property (assign, readonly) BOOL isRunning;

+ (instancetype)sharedInstance;

- (void)startServiceWithHost:(NSString *)host port:(int)port;
- (void)stopService;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
