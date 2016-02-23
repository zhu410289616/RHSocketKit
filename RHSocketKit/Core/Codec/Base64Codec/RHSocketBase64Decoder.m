//
//  RHSocketBase64Decoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketBase64Decoder.h"
#import "RHSocketException.h"

@interface RHSocketBase64Decoder ()
{
    NSStringEncoding _stringEncoding;
}

@end

@implementation RHSocketBase64Decoder

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
        NSString *base64Object = object;
        NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64Object options:0];
        stringObject = [[NSString alloc] initWithData:base64Data encoding:_stringEncoding];
    } else if ([object isKindOfClass:[NSData class]]) {
        NSString *base64Object = [[NSString alloc] initWithData:object encoding:_stringEncoding];
        NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64Object options:0];
        stringObject = [[NSString alloc] initWithData:base64Data encoding:_stringEncoding];
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
