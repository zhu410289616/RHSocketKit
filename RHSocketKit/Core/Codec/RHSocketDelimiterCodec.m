//
//  RHSocketDelimiterCodec.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/17.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterCodec.h"
#import "RHSocketConfig.h"
#import "RHPacketResponse.h"

@implementation RHSocketDelimiterCodec

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 8192;
        _delimiter = 0xff;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket data];
    NSAssert(data.length < _maxFrameSize, @"Encode data is too long ...");
    
    NSMutableData *sendData = [NSMutableData dataWithData:data];
    [sendData appendBytes:&_delimiter length:1];//在上行数据的末尾加上分隔符标记
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSUInteger dataLen = downstreamData.length;
    NSUInteger headIndex = 0;
    
    for (NSUInteger i=0; i<dataLen; i++) {
        //遍历数据的最大允许长度后，返回异常长度－1，进入channel的断开退出逻辑
        if (i >= _maxFrameSize) {
            return -1;
        }
        NSAssert(i < _maxFrameSize, @"Decode data is too long ...");
        //根据分隔符，获取一块数据包，类似得到一句完整的句子。然后output，触发上层逻辑
        uint8_t byte;
        [downstreamData getBytes:&byte range:NSMakeRange(i, 1)];
        if (byte == _delimiter) {
            NSInteger frameLen = i - headIndex;
            NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, frameLen)];
            RHPacketResponse *rsp = [[RHPacketResponse alloc] initWithData:frameData];
            [output didDecode:rsp];
            //
            headIndex = i + 1;
        }
    }
    return headIndex;
}

@end
