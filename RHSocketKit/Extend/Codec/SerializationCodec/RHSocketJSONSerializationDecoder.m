//
//  RHSocketJSONSerializationDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketJSONSerializationDecoder.h"
#import "NSDictionary+RHSocket.h"
#import "RHSocketException.h"

@implementation RHSocketJSONSerializationDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSDictionary *dictionaryObject = nil;
    
    id object = [downstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        dictionaryObject = [NSDictionary dictionaryWithJsonString:object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        dictionaryObject = object;
    } else if ([object isKindOfClass:[NSData class]]) {
        dictionaryObject = [NSDictionary dictionaryWithJsonData:object];
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
    }
    [downstreamPacket setObject:dictionaryObject];
    
    //责任链模式，丢给下一个处理器
    if (_nextDecoder) {
        return [_nextDecoder decode:downstreamPacket output:output];
    }
    
    [output didDecode:downstreamPacket];
    return 0;
}

@end
