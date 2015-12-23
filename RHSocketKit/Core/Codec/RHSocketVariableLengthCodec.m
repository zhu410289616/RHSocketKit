//
//  RHSocketVariableLengthCodec.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/17.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthCodec.h"
#import "RHSocketConfig.h"
#import "RHSocketUtils.h"
#import "RHPacketResponse.h"

@interface RHSocketVariableLengthCodec ()
{
    //头部长度数据的字节个数，默认为2
    int _headLength;
}

@end

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
        //剩余数据，不是完整的数据包，则break继续读取等待
        if (downstreamData.length - headIndex < _headLength + frameLen) {
            break;
        }
        //数据包(长度＋内容)
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _headLength + frameLen)];
        //去除数据长度后的数据内容
        RHPacketResponse *rsp = [[RHPacketResponse alloc] initWithData:[frameData subdataWithRange:NSMakeRange(_headLength, frameLen)]];
        [output didDecode:rsp];
        //调整已经解码数据
        headIndex += frameData.length;
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
        return [RHSocketUtils uint16FromBytes:dstData];
    }
    return [RHSocketUtils uint16FromBytes:lenData];
}

@end
