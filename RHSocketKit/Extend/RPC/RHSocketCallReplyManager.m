//
//  RHSocketCallReplyManager.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketCallReplyManager.h"
#import "MSWeakTimer.h"

@interface RHSocketCallReplyManager ()
{
    NSMutableDictionary *_callReplyMap;
    
    dispatch_queue_t _checkQueue;
    MSWeakTimer *_checkTimer;
}

@end

@implementation RHSocketCallReplyManager

- (instancetype)init
{
    if (self = [super init]) {
        _callReplyMap = [[NSMutableDictionary alloc] init];
        _checkQueue = dispatch_queue_create("com.zrh.RHSocketCallReplyCheck", NULL);
        [self startRefreshTimer];
    }
    return self;
}

- (void)stopRefreshTimer
{
    if (_checkTimer) {
        [_checkTimer invalidate];
        _checkTimer = nil;
    }
}

- (void)startRefreshTimer
{
    [self stopRefreshTimer];
    _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTimeout) userInfo:nil repeats:YES dispatchQueue:_checkQueue];
}

- (void)checkTimeout
{
    @synchronized(self) {
        NSMutableArray *timeoutCalls = [[NSMutableArray alloc] init];
        [_callReplyMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id<RHSocketCallReplyProtocol> tempCallReply = obj;
            if ([tempCallReply isTimeout]) {
                [timeoutCalls addObject:@([tempCallReply callReplyId])];
                //
                NSDictionary *userInfo = @{@"msg":@"Socket call is timeout."};
                NSError *error = [NSError errorWithDomain:@"RHSocketChannelProxy" code:-1 userInfo:userInfo];
                [tempCallReply onFailure:tempCallReply error:error];
            }//if
        }];
        for (NSNumber *callId in timeoutCalls) {
            [_callReplyMap removeObjectForKey:callId];
        }//for
    }//
}

- (void)addCallReply:(id<RHSocketCallReplyProtocol>)aCallReply
{
    @synchronized(self) {
        [_callReplyMap setObject:aCallReply forKey:@([aCallReply callReplyId])];
    }
}

- (id<RHSocketCallReplyProtocol>)getCallReplyWithId:(NSInteger)aCallReplyId
{
    @synchronized(self) {
        return [_callReplyMap objectForKey:@(aCallReplyId)];
    }
}

- (void)removeCallReplyWithId:(NSInteger)aCallReplyId
{
    @synchronized(self) {
        [_callReplyMap removeObjectForKey:@(aCallReplyId)];
    }
}

- (void)removeAllCallReply
{
    @synchronized(self) {
        [_callReplyMap removeAllObjects];
    }
}

@end
