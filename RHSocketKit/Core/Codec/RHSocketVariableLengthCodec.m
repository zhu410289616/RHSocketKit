//
//  RHSocketVariableLengthCodec.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/17.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthCodec.h"
#import "RHSocketConfig.h"
#import "RHPacketResponse.h"

@implementation RHSocketVariableLengthCodec

- (instancetype)init
{
    if (self = [super init]) {
        _headLength = 2;
        _headDataShouldSwap = YES;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket data];
    NSAssert(data.length > 0 , @"Encode data is too short ...");
    
    uint16_t dataLen = data.length;
    NSMutableData *sendData = [[NSMutableData alloc] init];
    [sendData appendBytes:&dataLen length:2];
    [sendData appendData:data];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSUInteger headIndex = 0;
    //先读区2个字节的协议长度 (前2个字节为数据包的长度)
    while (downstreamData && downstreamData.length - headIndex > _headLength) {
        NSData *lenData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _headLength)];
        NSUInteger frameLen = [self frameLengthWithData:lenData shouldSwapData:_headDataShouldSwap];
        
        if (downstreamData.length - headIndex < _headLength + frameLen) {
            break;
        }
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _headLength + frameLen)];
        RHPacketResponse *rsp = [[RHPacketResponse alloc] initWithData:frameData];
        [output didDecode:rsp];
        //
        headIndex += frameLen;
    }//while
    return headIndex;
}

/**
 *  二机制和数值长度转换
 *
 *  @param lenData    协议帧中包头长度字节数据
 *  @param shouldSwap 长度数据是否需要高低位交换
 *
 *  @return 包头长度
 */
- (uint16_t)frameLengthWithData:(NSData *)lenData shouldSwapData:(BOOL)shouldSwap
{
    if (shouldSwap) {
        NSMutableData *dstData = [[NSMutableData alloc] init];
        for (NSUInteger i=0; i<lenData.length; i++) {
            [dstData appendData:[lenData subdataWithRange:NSMakeRange(lenData.length-1-i, 1)]];
        }//for
        return [self lengthFromBytes:dstData];
    }
    return [self lengthFromBytes:lenData];
}

- (NSData *)bytesFromLength:(uint32_t)length
{
    NSMutableData *lenData = [[NSMutableData alloc] init];
    
    NSUInteger val = length;
    do {
        int8_t digit = val % 256;
        val = val >> 8;
        [lenData appendBytes:&digit length:1];
    } while (val > 0);
    
    return lenData;
}

- (uint32_t)lengthFromBytes:(NSData *)lenData
{
    NSUInteger byteCount = MIN(4, lenData.length);
    
    const char *bytes = lenData.bytes;
    int multiplier = 1;
    uint32_t length = 0;
    
    for (NSUInteger i=0; i<byteCount; i++) {
        int8_t digit = bytes[i];
        length += digit * multiplier;
        multiplier *= 256;
    }//for
    
    return length;
}

@end
