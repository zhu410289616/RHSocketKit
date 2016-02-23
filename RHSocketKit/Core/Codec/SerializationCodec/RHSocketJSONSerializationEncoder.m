//
//  RHSocketJSONSerializationEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketJSONSerializationEncoder.h"
#import "RHSocketException.h"
#import "NSDictionary+RHSocket.h"

@implementation RHSocketJSONSerializationEncoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *dataObject = nil;
    
    id object = [upstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *stringObject = object;
        NSDictionary *dictionaryObject = [NSDictionary dictionaryWithJsonString:stringObject];
        dataObject = [NSJSONSerialization dataWithJSONObject:dictionaryObject options:NSJSONWritingPrettyPrinted error:nil];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        dataObject = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    } else if ([object isKindOfClass:[NSData class]]) {
        dataObject = object;
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
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
