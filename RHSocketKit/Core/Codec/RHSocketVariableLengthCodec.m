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

@interface RHSocketVariableLengthCodec ()
{
    NSUInteger _headLength;
}

@end

@implementation RHSocketVariableLengthCodec

- (instancetype)init
{
    if (self = [super init]) {
        _headLength = 2;
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

- (NSData *)encode:(NSData *)upstreamData
{
    NSAssert(upstreamData.length > 0 , @"Encode data is too short ...");
    
    uint16_t dataLen = upstreamData.length;
    NSMutableData *sendData = [[NSMutableData alloc] init];
    [sendData appendBytes:&dataLen length:2];
    [sendData appendData:upstreamData];
    return sendData;
}

- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSUInteger headIndex = 0;
    //先读区2个字节的协议长度 (前2个字节为数据包的长度)
    while (downstreamData && downstreamData.length - headIndex > _headLength) {
        NSData *lenData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _headLength)];
        NSUInteger frameLen = [self frameLengthWithData:lenData];
        
        if (downstreamData.length - headIndex < frameLen) {
            break;
        }
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, frameLen)];
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
    uint16_t frameLen = 0;
    if (shouldSwap) {
        [lenData getBytes:&frameLen length:_headLength];
    } else {
        frameLen = ntohs((uint16_t)lenData.bytes);
    }
    return frameLen;
}

- (NSUInteger)frameLengthWithData:(NSData *)lenData
{
    return [self frameLengthWithData:lenData shouldSwapData:YES];
}

@end
