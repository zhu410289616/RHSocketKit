//
//  RHPacketResponse.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/18.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketResponse.h"

@interface RHPacketResponse ()
{
    NSMutableData *_packetData;
}

@end

@implementation RHPacketResponse

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _packetData = [NSMutableData dataWithData:data];
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

- (NSInteger)pid
{
    return 0;
}

@end
