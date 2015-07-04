//
//  RHPacketFrame.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketFrame.h"

@interface RHPacketFrame ()
{
    NSData *_frameData;
}

@end

@implementation RHPacketFrame

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _frameData = [NSData dataWithData:data];
    }
    return self;
}

- (NSInteger)tag
{
    return 0;
}

- (NSData *)data
{
    return _frameData;
}

@end
