//
//  RHSocketHttpCodec.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/18.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpCodec.h"
#import "RHSocketConfig.h"
#import "RHPacketHttpResponse.h"

@implementation RHSocketHttpCodec

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket data];
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    NSData *crlfData = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    [sendData appendData:crlfData];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSUInteger dataLen = downstreamData.length;
    NSInteger headIndex = 0;
    int crlfCount = 0;
    
    for (NSInteger i=0; i<dataLen; i++) {
        uint8_t byte;
        [downstreamData getBytes:&byte range:NSMakeRange(i, 1)];
        if (byte == 0x0a) {
            crlfCount++;
        }
        if (crlfCount == 2) {
            NSInteger packetLen = i - headIndex;
            NSData *packetData = [downstreamData subdataWithRange:NSMakeRange(headIndex, packetLen)];
            RHPacketHttpResponse *rsp = [[RHPacketHttpResponse alloc] initWithData:packetData];
            [output didDecode:rsp];
            
            headIndex = i + 1;
            crlfCount = 0;
        }
    }//for
    return headIndex;
}

@end
