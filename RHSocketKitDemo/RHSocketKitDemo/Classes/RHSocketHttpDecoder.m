//
//  RHSocketHttpDecoder.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/2.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpDecoder.h"
#import "RHSocketConfig.h"
#import "RHPacketHttpResponse.h"

@interface RHSocketHttpDecoder ()
{
    NSMutableData *_receiveData;
}

@end

@implementation RHSocketHttpDecoder

- (NSUInteger)decodeData:(NSData *)data decoderOutput:(id<RHSocketDecoderOutputDelegate>)output tag:(long)tag
{
    @synchronized(self) {
        if (_receiveData) {
            [_receiveData appendData:data];
        } else {
            _receiveData = [NSMutableData dataWithData:data];
        }
        
        NSUInteger dataLen = _receiveData.length;
        NSInteger headIndex = 0;
        int crlfCount = 0;
        
        for (NSInteger i=0; i<dataLen; i++) {
            uint8_t byte;
            [_receiveData getBytes:&byte range:NSMakeRange(i, 1)];
            if (byte == 0x0a) {
                crlfCount++;
            }
            if (crlfCount == 2) {
                NSInteger packetLen = i - headIndex;
                NSData *packetData = [_receiveData subdataWithRange:NSMakeRange(headIndex, packetLen)];
                RHPacketHttpResponse *rsp = [[RHPacketHttpResponse alloc] initWithData:packetData];
                [output didDecode:rsp tag:0];
                headIndex = i + 1;
                crlfCount = 0;
            }
        }
        
        NSData *remainData = [_receiveData subdataWithRange:NSMakeRange(headIndex, dataLen-headIndex)];
        [_receiveData setData:remainData];
        
        return _receiveData.length;
    }//@synchronized
}

@end
