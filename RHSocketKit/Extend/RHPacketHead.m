//
//  RHPacketHead.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/19.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketHead.h"

@interface RHPacketHead ()
{
    NSData *_packetData;
}

@end

@implementation RHPacketHead

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

- (NSUInteger)packetLength
{
    NSUInteger len = 0;
    if (_packetData.length >= 2) {
        [_packetData getBytes:&len range:NSMakeRange(0, 2)];
    }
    return 0;
}

- (NSInteger)packetCommand
{
    NSInteger command = -1;
    if (_packetData.length >= 4) {
        [_packetData getBytes:&command range:NSMakeRange(2, 2)];
    }
    return command;
}

@end
