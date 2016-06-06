//
//  RHSocketHttpEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpEncoder.h"
#import "RHSocketHttpRequest.h"

@implementation RHSocketHttpEncoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    RHSocketHttpRequest *req = (RHSocketHttpRequest *)upstreamPacket;
    NSData *data = [req data];
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    NSData *crlfData = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    [sendData appendData:crlfData];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    NSLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

@end
