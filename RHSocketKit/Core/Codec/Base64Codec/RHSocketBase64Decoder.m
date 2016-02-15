//
//  RHSocketBase64Decoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketBase64Decoder.h"
#import "Base64.h"

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
    NSString *base64Object = nil;
    
    id object = [downstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        base64Object = object;
    } else if ([object isKindOfClass:[NSData class]]) {
        base64Object = [[NSString alloc] initWithData:object encoding:_stringEncoding];
    }
    
    //做base64解码
    NSString *stringObject = nil;
    if (stringObject.length > 0) {
        stringObject = [base64Object base64DecodedString];
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
