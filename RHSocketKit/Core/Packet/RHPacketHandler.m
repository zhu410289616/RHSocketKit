//
//  RHPacketHandler.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHPacketHandler.h"

@implementation RHPacketHandler

@synthesize object;

@end

@interface RHPacketUpstreamHandler ()
{
    NSTimeInterval _timeout;
}

@end

@implementation RHPacketUpstreamHandler

@synthesize object;
@synthesize pid;

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
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

@implementation RHPacketDownstreamHandler

@synthesize object;
@synthesize pid;

@end