//
//  RHSocketHttpEncoder.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/2.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpEncoder.h"
#import "RHSocketConfig.h"

@implementation RHSocketHttpEncoder

- (void)encodePacket:(id<RHSocketPacketContent>)packet encoderOutput:(id<RHSocketEncoderOutputDelegate>)output
{
    NSData *data = [packet data];
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    NSData *crlfData = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    [sendData appendData:crlfData];
    
    NSTimeInterval timeout = [packet timeout];
    NSInteger tag = [packet tag];
    RHSocketLog(@"tag:%ld, timeout: %f, data: %@", (long)tag, timeout, sendData);
    [output didEncode:sendData timeout:timeout tag:tag];
}

@end
