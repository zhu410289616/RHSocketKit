//
//  RHSocketDelimiterEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketUtils.h"
#import "RHSocketException.h"

@implementation RHSocketDelimiterEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _delimiterData = [RHSocketUtils CRLFData];
        _maxFrameSize = 8192;
    }
    return self;
}

- (instancetype)initWithDelimiter:(uint8_t)aDelimiter maxFrameSize:(NSUInteger)aMaxFrameSize
{
    if (self = [super init]) {
        _delimiterData = [NSData dataWithBytes:&aDelimiter length:1];
        _maxFrameSize = aMaxFrameSize;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket dataWithPacket];
    if (data.length == 0) {
        RHSocketLog(@"[Encode] object data is nil ...");
        return;
    }//
    
    if (data.length >= _maxFrameSize - 1) {
        [RHSocketException raiseWithReason:@"[Encode] Too Long Frame ..."];
        return;
    }
    
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    [sendData appendData:_delimiterData];//在上行数据的末尾加上分隔符标记
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

@end
