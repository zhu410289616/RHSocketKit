//
//  RHSocketDelimiterEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketException.h"

@implementation RHSocketDelimiterEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _delimiter = 0xff;
        _maxFrameSize = 8192;
    }
    return self;
}

- (instancetype)initWithDelimiter:(uint8_t)aDelimiter maxFrameSize:(NSUInteger)aMaxFrameSize
{
    if (self = [super init]) {
        _delimiter = aDelimiter;
        _maxFrameSize = aMaxFrameSize;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    id object = [upstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:@"[Encode] object should be NSData ..."];
        return;
    }
    
    NSData *data = object;
    if (data.length >= _maxFrameSize - 1) {
        [RHSocketException raiseWithReason:@"[Encode] Too Long Frame ..."];
        return;
    }
    
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    [sendData appendBytes:&_delimiter length:1];//在上行数据的末尾加上分隔符标记
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

@end
