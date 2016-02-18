//
//  RHSocketProtobufDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketProtobufDecoder.h"
#import "RHSocketException.h"

@implementation RHSocketProtobufDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSData *dataObject = nil;
    
    id object = [downstreamPacket object];
    if ([object isKindOfClass:[NSData class]]) {
        dataObject = object;
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
    }
    [downstreamPacket setObject:dataObject];
    
    //责任链模式，丢给下一个处理器
    if (_nextDecoder) {
        return [_nextDecoder decode:downstreamPacket output:output];
    }
    
    [output didDecode:downstreamPacket];
    return 0;
}

@end
