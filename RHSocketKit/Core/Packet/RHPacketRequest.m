//
//  RHPacketRequest.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/18.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketRequest.h"

@interface RHPacketRequest ()
{
    NSData *_packetData;
    NSTimeInterval _timeout;
}

@end

@implementation RHPacketRequest

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (NSData *)data
{
    return _packetData;
}

- (void)setData:(NSData *)data
{
    _packetData = [NSMutableData dataWithData:data];
}

- (NSTimeInterval)timeout
{
    return _timeout;
}

- (void)setTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
}

@end
