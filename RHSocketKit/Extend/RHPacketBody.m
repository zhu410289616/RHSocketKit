//
//  RHPacketBody.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/19.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketBody.h"

@interface RHPacketBody ()
{
    NSData *_packetData;
    NSTimeInterval _timeout;
}

@end

@implementation RHPacketBody

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _packetData = [NSData dataWithData:data];
    }
    return self;
}

- (NSInteger)tag
{
    return 0;
}

- (NSData *)data
{
    return _packetData;
}

- (void)setData:(NSData *)data
{
    _packetData = [NSData dataWithData:data];
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
