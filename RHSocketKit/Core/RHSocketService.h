//
//  RHSocketService.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketEncoderProtocol.h"
#import "RHSocketDecoderProtocol.h"

extern NSString *const kNotificationSocketServiceState;
extern NSString *const kNotificationSocketPacketRequest;
extern NSString *const kNotificationSocketPacketResponse;

@interface RHSocketService : NSObject <RHSocketEncoderOutputDelegate, RHSocketDecoderOutputDelegate>

@property (nonatomic, copy) NSString *serverHost;
@property (nonatomic, assign) int serverPort;

@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;

@property (assign, readonly) BOOL isRunning;

+ (instancetype)sharedInstance;

- (void)startServiceWithHost:(NSString *)host port:(int)port;
- (void)stopService;

- (void)asyncSendPacket:(id<RHSocketPacketContent>)packet;

@end
