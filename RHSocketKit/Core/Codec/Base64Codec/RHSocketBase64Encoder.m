//
//  RHSocketBase64Encoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketBase64Encoder.h"
#import "RHSocketException.h"

@interface RHSocketBase64Encoder ()
{
    NSStringEncoding _stringEncoding;
}

@end

@implementation RHSocketBase64Encoder

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

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSString *base64Object = nil;
    
    id object = [upstreamPacket object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *stringObject = object;
        //string -> base64 string
        NSData *base64Data = [stringObject dataUsingEncoding:_stringEncoding];
        base64Object = [base64Data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    } else if ([object isKindOfClass:[NSData class]]) {
        NSData *dataObject = object;
        base64Object = [dataObject base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//data -> base64 string
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
    }
    
    //做base64编码
    NSData *dataObject = nil;
    if (base64Object.length > 0) {
        dataObject = [base64Object dataUsingEncoding:_stringEncoding];
    }
    
    if (dataObject.length <= 0) {
        return;
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
