//
//  RHSocketVariableLengthDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthDecoder.h"
#import "RHPacketFrame.h"

int const kProtocolFrameLengthOfHead = 2;

@interface RHSocketVariableLengthDecoder ()
{
    NSMutableData *_receiveData;
}

@end

@implementation RHSocketVariableLengthDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _receiveData = [[NSMutableData alloc] init];
    }
    return self;
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
        [lenData getBytes:&frameLen length:kProtocolFrameLengthOfHead];
    } else {
        frameLen = ntohs((uint16_t)lenData.bytes);
    }
    return frameLen;
}

- (NSUInteger)frameLengthWithData:(NSData *)lenData
{
    return [self frameLengthWithData:lenData shouldSwapData:YES];
}

- (NSUInteger)decodeData:(NSData *)data decoderOutput:(id<RHSocketDecoderOutputDelegate>)output tag:(long)tag
{
    @synchronized(self) {
        if (data.length < 1) {
            return _receiveData.length;
        }
        [_receiveData appendData:data];
        
        NSUInteger headIndex = 0;
        //先读区2个字节的协议长度 (前2个字节为数据包的长度)
        while (_receiveData && _receiveData.length - headIndex > kProtocolFrameLengthOfHead) {
            NSData *lenData = [_receiveData subdataWithRange:NSMakeRange(headIndex, kProtocolFrameLengthOfHead)];
            NSUInteger frameLen = [self frameLengthWithData:lenData];
            
            if (_receiveData.length - headIndex < frameLen) {
                break;
            }
            NSData *frameData = [_receiveData subdataWithRange:NSMakeRange(headIndex, frameLen)];
            RHPacketFrame *frame = [[RHPacketFrame alloc] initWithData:frameData];
            [output didDecode:frame tag:tag];
            headIndex += frameLen;
        }
        NSData *remainData = [_receiveData subdataWithRange:NSMakeRange(headIndex, _receiveData.length-headIndex)];
        [_receiveData setData:remainData];
        
        return _receiveData.length;
    }//@synchronized
}

@end
