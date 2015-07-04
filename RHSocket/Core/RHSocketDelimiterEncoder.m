//
//  RHSocketDelimiterEncoder.m
//  RHToolkit
//
//  Created by zhuruhong on 15/6/30.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketConfig.h"

@implementation RHSocketDelimiterEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 8192;
        _delimiter = 0xff;
    }
    return self;
}

- (void)encodePacket:(id<RHSocketPacketContent>)packet encoderOutput:(id<RHSocketEncoderOutputDelegate>)output
{
    NSData *data = [packet data];
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    [sendData appendBytes:&_delimiter length:1];
    NSAssert(sendData.length < _maxFrameSize, @"Encode frame is too long...");
    
    NSTimeInterval timeout = [packet timeout];
    NSInteger tag = [packet tag];
    RHSocketLog(@"tag:%ld, timeout: %f, data: %@", (long)tag, timeout, data);
    [output didEncode:data timeout:timeout tag:tag];
}

@end
