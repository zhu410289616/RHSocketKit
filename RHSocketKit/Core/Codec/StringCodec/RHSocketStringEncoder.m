//
//  RHSocketStringEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketStringEncoder.h"

@interface RHSocketStringEncoder ()
{
    NSStringEncoding _stringEncoding;
}

@end

@implementation RHSocketStringEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _stringEncoding = NSUTF8StringEncoding;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *dataObject = nil;
    
    id object = [upstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *stringObject = object;
        dataObject = [stringObject dataUsingEncoding:_stringEncoding];
    } else if ([object isKindOfClass:[NSData class]]) {
        dataObject = object;
    }
    
    //责任链模式，丢给下一个处理器
    if (_nextEncoder) {
        [upstreamPacket setObject:dataObject];
        [_nextEncoder encode:upstreamPacket output:output];
        return;
    }
    
    [output didEncode:dataObject timeout:[upstreamPacket timeout]];
}

@end
