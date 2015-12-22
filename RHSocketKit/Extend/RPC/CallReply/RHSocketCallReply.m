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
    return [_request timeout];
}

- (BOOL)isTimeout
{
    time_t currentTime = time(0);
    if (currentTime - _startTime >= [_request timeout]) {
        return YES;
    }
    return NO;
}

- (void)onFailure:(id<RHSocketCallReplyProtocol>)aCallReply error:(NSError *)error
{
    RHSocketLog(@"%@ onFailure: %@", [self class], error.description);
    //TODO: 请求失败
    [_delegate onFailure:aCallReply error:error];
}

- (void)onSuccess:(id<RHSocketCallReplyProtocol>)aCallReply response:(id<RHDownstreamPacket>)response
{
    RHSocketLog(@"%@ onSuccess: %@", [self class], [response data]);
    //TODO: 请求成功
    [_delegate onSuccess:aCallReply response:response];
}

@end
