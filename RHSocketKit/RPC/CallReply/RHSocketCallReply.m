//
//  RHSocketCallReply.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketCallReply.h"

@interface RHSocketCallReply ()
{
    id<RHUpstreamPacket> _request;
    time_t _startTime;
}

@end

@implementation RHSocketCallReply

- (void)setRequest:(id<RHUpstreamPacket>)request
{
    _request = request;
}

- (id<RHUpstreamPacket>)request
{
    _startTime = time(0);
    return _request;
}

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
