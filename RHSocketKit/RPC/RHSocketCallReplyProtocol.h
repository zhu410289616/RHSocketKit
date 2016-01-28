//
//  RHSocketCallReplyProtocol.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@protocol RHSocketCallReplyProtocol;

/**
 *  RPC呼叫协议
 */
@protocol RHSocketCallProtocol <NSObject>

@required

@property (nonatomic, strong) id<RHUpstreamPacket> request;

@end

/**
 *  RPC应答协议
 */
@protocol RHSocketReplyProtocol <NSObject>

@required

- (void)onSuccess:(id<RHSocketCallReplyProtocol>)aCallReply response:(id<RHDownstreamPacket>)response;
- (void)onFailure:(id<RHSocketCallReplyProtocol>)aCallReply error:(NSError *)error;

@end

/**
 *  RPC相关协议
 */
@protocol RHSocketCallReplyProtocol <RHSocketCallProtocol, RHSocketReplyProtocol>

@required

- (NSInteger)callReplyId;
- (NSTimeInterval)callReplyTimeout;
- (BOOL)isTimeout;

@end
