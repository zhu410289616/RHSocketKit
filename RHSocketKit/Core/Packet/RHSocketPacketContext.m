//
//  RHSocketPacketContext.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketPacketContext.h"

@implementation RHSocketPacketContext

@synthesize object = _object;

- (instancetype)initWithObject:(id)aObject
{
    if (self = [super init]) {
        _object = aObject;
    }
    return self;
}

@end

@implementation RHSocketPacketUpstreamContext

@synthesize timeout = _timeout;

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (instancetype)initWithObject:(id)aObject
{
    if (self = [super initWithObject:aObject]) {
        _timeout = -1;
    }
    return self;
}

@end

@implementation RHSocketPacketDownstreamContext

@end

@implementation RHSocketPacketRequest

@synthesize pid;

@end

@implementation RHSocketPacketResponse

@synthesize pid;

@end
