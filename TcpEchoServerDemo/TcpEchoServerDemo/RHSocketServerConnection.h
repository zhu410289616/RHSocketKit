//
//  RHSocketServerConnection.h
//  TcpEchoServerDemo
//
//  Created by zhuruhong on 16/9/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class RHSocketServerConnection;

@protocol RHSocketServerConnectionDelegate <NSObject>

- (void)didDisconnect:(RHSocketServerConnection *)con withError:(NSError *)err;

@end

@interface RHSocketServerConnection : NSObject

@property (nonatomic, weak) id<RHSocketServerConnectionDelegate> delegate;

- (instancetype)initWithAsyncSocket:(GCDAsyncSocket *)aSocket configuration:(id)aConfig;

- (void)start;
- (void)stop;

@end
