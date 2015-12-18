//
//  RHSocketChannel.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/15.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@class RHSocketChannel;

@protocol RHSocketChannelDelegate <NSObject>

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port;
- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error;
- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet;

@end

@interface RHSocketChannel : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) int port;

@property (nonatomic, strong) id<RHSocketCodecProtocol> codec;

@property (nonatomic, weak) id<RHSocketChannelDelegate> delegate;

- (instancetype)initWithHost:(NSString *)host port:(int)port;

- (void)openConnection;
- (void)closeConnection;
- (BOOL)isConnected;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

@end
