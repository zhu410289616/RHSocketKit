//
//  RHWebSocket.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/18.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHWebSocketConfig.h"
#import "RHSocketCodecProtocol.h"

typedef NS_ENUM(NSInteger, RHWebSocketStatus) {
    RHWebSocketStatusUnknown,
    RHWebSocketStatusHandshake,
    RHWebSocketStatusActive
};

@class RHWebSocket;

@protocol RHWebSocketDelegate <NSObject>

@required

- (void)socket:(RHWebSocket *)webSocket didConnectToHost:(NSString *)host port:(uint16_t)port;
- (void)socket:(RHWebSocket *)webSocket didHandshakeFinished:(RHWebSocketConfig *)config;
- (void)socket:(RHWebSocket *)webSocket didReceived:(id<RHDownstreamPacket>)packet;
- (void)socket:(RHWebSocket *)webSocket didDisconnectWithError:(NSError *)error;

@end

@interface RHWebSocket : NSObject

@property (nonatomic, strong) RHWebSocketConfig *config;

//@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
//@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;

@property (nonatomic, weak) id<RHWebSocketDelegate> delegate;

/** socket状态：连接，握手，活跃 */
@property (nonatomic, assign) RHWebSocketStatus status;

- (instancetype)initWithConfig:(RHWebSocketConfig *)config;

- (void)openConnection;
- (void)closeConnection;
- (BOOL)isConnected;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
