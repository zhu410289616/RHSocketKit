//
//  RHSocketPacketContext.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketPacketContext.h"

#pragma mark - RHSocketPacketContext

@implementation RHSocketPacketContext

@synthesize object = _object;

- (instancetype)initWithObject:(id)aObject
{
    if (self = [super init]) {
        _object = aObject;
    }
    return self;
}

- (NSData *)dataWithPacket
{
    if ([_object isKindOfClass:[NSData class]]) {
        return _object;
    } else if ([_object isKindOfClass:[NSString class]]) {
        NSString *stringObject = _object;
        return [stringObject dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

- (NSString *)stringWithPacket
{
    if ([_object isKindOfClass:[NSString class]]) {
        return _object;
    } else if ([_object isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:_object encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

@end

#pragma mark - RHSocketPacketRequest

@implementation RHSocketPacketRequest

@synthesize pid;
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

#pragma mark - RHSocketPacketResponse

@implementation RHSocketPacketResponse

@synthesize pid;

@end
