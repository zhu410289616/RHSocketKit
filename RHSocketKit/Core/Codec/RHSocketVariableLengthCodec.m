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
#import "RHSocketException.h"

@implementation RHSocketVariableLengthCodec

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 65536;
        _countOfLengthByte = 2;
        _reverseOfLengthByte = NO;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket data];
    if (data.length == 0) {
        [RHSocketException raiseWithReason:@"[Encode] Too short Frame ..."];
        return;
    }//
    
    if (data.length >= _maxFrameSize - _countOfLengthByte) {
        [RHSocketException raiseWithReason:@"[Encode] Too Long Frame ..."];
        return;
    }//
    
    //可变长度编码，数据块的前两个字节为后续完整数据块的长度
    NSUInteger dataLen = data.length;
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //将数据长度转换为长度字节，写入到数据块中。这里根据head占的字节个数转换data长度，默认为2个字节
    NSData *headData = [RHSocketUtils bytesFromValue:dataLen byteCount:_countOfLengthByte];
    if (!_reverseOfLengthByte) {
        headData = [self dataWithReverse:headData];
    }
    [sendData appendData:headData];
    [sendData appendData:data];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSUInteger headIndex = 0;
    //先读区2个字节的协议长度 (前2个字节为数据包的长度)
    while (downstreamData && downstreamData.length - headIndex > _countOfLengthByte) {
        NSData *lenData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _countOfLengthByte)];
        //长度字节数据，可能存在高低位互换，通过数值转换工具处理
        if (!_reverseOfLengthByte) {
            lenData = [self dataWithReverse:lenData];
        }
        NSUInteger frameLen = [RHSocketUtils valueFromBytes:lenData];
        if (frameLen >= _maxFrameSize - _countOfLengthByte) {
            [RHSocketException raiseWithReason:@"[Decode] Too Long Frame ..."];
            return -1;
        }//
        
        //剩余数据，不是完整的数据包，则break继续读取等待
        if (downstreamData.length - headIndex < _countOfLengthByte + frameLen) {
            break;
        }
        //数据包(长度＋内容)
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _countOfLengthByte + frameLen)];
        //去除数据长度后的数据内容
        RHPacketResponse *rsp = [[RHPacketResponse alloc] initWithData:[frameData subdataWithRange:NSMakeRange(_countOfLengthByte, frameLen)]];
        [output didDecode:rsp];
        //调整已经解码数据
        headIndex += frameData.length;
    }//while
    return headIndex;
}

/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
- (NSData *)dataWithReverse:(NSData *)srcData
{
    NSMutableData *dstData = [[NSMutableData alloc] init];
    for (NSUInteger i=0; i<srcData.length; i++) {
        [dstData appendData:[srcData subdataWithRange:NSMakeRange(srcData.length-1-i, 1)]];
    }//for
    return dstData;
}

@end
