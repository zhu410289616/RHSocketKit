//
//  RHSocketHttpDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpDecoder.h"
#import "RHSocketHttpResponse.h"

@implementation RHSocketHttpDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSData *downstreamData = [downstreamPacket object];
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
            
            RHSocketHttpResponse *rsp = [[RHSocketHttpResponse alloc] initWithObject:packetData];
            
            if (_nextDecoder) {
                [_nextDecoder decode:rsp output:output];
            } else {
                [output didDecode:rsp];
            }
            
            headIndex = i + 1;
            crlfCount = 0;
        }
    }//for
    return headIndex;
}

@end
