//
//  RHSocketVariableLengthEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketConfig.h"

@implementation RHSocketVariableLengthEncoder

- (void)encodePacket:(id<RHSocketPacketContent>)packet encoderOutput:(id<RHSocketEncoderOutputDelegate>)output
{
    NSData *data = [packet data];
    NSAssert(data.length > 0 , @"Encode data is too short ...");
    
    uint16_t dataLen = data.length;
    NSMutableData *sendData = [[NSMutableData alloc] init];
    [sendData appendBytes:&dataLen length:2];
    [sendData appendData:data];
    NSTimeInterval timeout = [packet timeout];
    NSInteger tag = [packet tag];
    
    RHSocketLog(@"tag:%ld, timeout: %f, sendData: %@", (long)tag, timeout, sendData);
    [output didEncode:sendData timeout:timeout tag:tag];
}

@end
