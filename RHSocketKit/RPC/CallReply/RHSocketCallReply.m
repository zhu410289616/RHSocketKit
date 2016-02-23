//
//  RHSocketCallReply.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketCallReply.h"

typedef void(^RHSocketReplySuccessBlock)(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket>response);
typedef void(^RHSocketReplyFailureBlock)(id<RHSocketCallReplyProtocol> callReply, NSError *error);

@interface RHSocketCallReply ()
{
    id<RHUpstreamPacket> _request;
    time_t _startTime;
    
    RHSocketReplySuccessBlock _successBlock;
    RHSocketReplyFailureBlock _failureBlock;
}

@end

@implementation RHSocketCallReply

#pragma mark - 

- (void)setSuccessBlock:(void (^)(id<RHSocketCallReplyProtocol>, id<RHDownstreamPacket>))successBlock
{
    _successBlock = successBlock;
}

- (void)setFailureBlock:(void (^)(id<RHSocketCallReplyProtocol>, NSError *))failureBlock
{
    _failureBlock = failureBlock;
}

- (void)setRequest:(id<RHUpstreamPacket>)request
{
    _request = request;
}

- (id<RHUpstreamPacket>)request
{
    _startTime = time(0);
    return _request;
}

#pragma mark - RHSocketCallProtocol

- (NSInteger)callReplyId
{
    return [_request pid];
}

- (NSTimeInterval)callReplyTimeout
{
    if ([_request timeout] < 0) {
        return LONG_MAX;
    }
    return [_request timeout];
}

- (BOOL)isTimeout
{
    time_t currentTime = time(0);
    if (currentTime - _startTime >= [self callReplyTimeout]) {
        return YES;
    }
    return NO;
}

#pragma mark - RHSocketReplyProtocol

- (void)onFailure:(id<RHSocketCallReplyProtocol>)aCallReply error:(NSError *)error
{
    RHSocketLog(@"%@ onFailure: %@", [self class], error.description);
    //请求失败
    if (_failureBlock) {
        _failureBlock(aCallReply, error);
    }
}

- (void)onSuccess:(id<RHSocketCallReplyProtocol>)aCallReply response:(id<RHDownstreamPacket>)response
{
    RHSocketLog(@"%@ onSuccess: %@", [self class], [response object]);
    //请求成功
    if (_successBlock) {
        _successBlock(aCallReply, response);
    }
}

@end
