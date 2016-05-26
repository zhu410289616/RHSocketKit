//
//  RHSocketStringDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketStringDecoder.h"
#import "RHSocketException.h"

@interface RHSocketStringDecoder ()
{
    NSStringEncoding _stringEncoding;
}

@end

@implementation RHSocketStringDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _stringEncoding = NSUTF8StringEncoding;
    }
    return self;
}

- (instancetype)initWithStringEncoding:(NSStringEncoding)stringEncoding
{
    if (self = [super init]) {
        _stringEncoding = stringEncoding;
    }
    return self;
}

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSString *stringObject = nil;
    
    id object = [downstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        stringObject = object;
    } else if ([object isKindOfClass:[NSData class]]) {
        stringObject = [[NSString alloc] initWithData:object encoding:_stringEncoding];
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
    }
    [downstreamPacket setObject:stringObject];
    
    //责任链模式，丢给下一个处理器
    if (_nextDecoder) {
        return [_nextDecoder decode:downstreamPacket output:output];
    }
    
    [output didDecode:downstreamPacket];
    return 0;
}

@end
