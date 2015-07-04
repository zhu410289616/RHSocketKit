//
//  RHSocketVariableLengthDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthDecoder.h"
#import "RHPacketFrame.h"

@interface RHSocketVariableLengthDecoder ()
{
    NSMutableData *_receiveData;
}

@end

@implementation RHSocketVariableLengthDecoder

- (NSUInteger)decodeData:(NSData *)data decoderOutput:(id<RHSocketDecoderOutputDelegate>)output tag:(long)tag
{
    @synchronized(self) {
        if (_receiveData) {
            [_receiveData appendData:data];
        } else {
            _receiveData = [NSMutableData dataWithData:data];
        }
        
        NSUInteger headIndex = 0;
        //先读区2个字节的协议长度 (前2个字节为数据包的长度)
        while (_receiveData && _receiveData.length > 2) {
            NSData *lenData = [_receiveData subdataWithRange:NSMakeRange(headIndex, 2)];
            uint16_t frameLen;
            [lenData getBytes:&frameLen length:2];
            
            if (_receiveData.length < frameLen) {
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
