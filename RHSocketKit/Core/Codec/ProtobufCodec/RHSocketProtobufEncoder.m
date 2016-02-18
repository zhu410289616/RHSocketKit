//
//  RHSocketProtobufEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketProtobufEncoder.h"
#import <ProtocolBuffers/ProtocolBuffers.h>
#import "RHSocketException.h"

@implementation RHSocketProtobufEncoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *dataObject = nil;
    
    id object = [upstreamPacket object];
    if ([object isKindOfClass:[PBGeneratedMessage class]]) {
        PBGeneratedMessage *pb = object;
        dataObject = [pb data];
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
