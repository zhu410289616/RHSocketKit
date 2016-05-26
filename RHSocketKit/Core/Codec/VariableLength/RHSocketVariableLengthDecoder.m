//
//  RHSocketVariableLengthDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthDecoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"
#import "RHSocketPacketContext.h"

@implementation RHSocketVariableLengthDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 65536;
        _countOfLengthByte = 2;
        _reverseOfLengthByte = YES;
    }
    return self;
}

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    id object = [downstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:@"[Decode] object should be NSData ..."];
        return -1;
    }
    
    NSData *downstreamData = object;
    NSUInteger headIndex = 0;
    
    //先读区2个字节的协议长度 (前2个字节为数据包的长度)
    while (downstreamData && downstreamData.length - headIndex > _countOfLengthByte) {
        NSData *lenData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _countOfLengthByte)];
        //长度字节数据，可能存在高低位互换，通过数值转换工具处理
        NSUInteger frameLen = (NSUInteger)[RHSocketUtils valueFromBytes:lenData reverse:_reverseOfLengthByte];
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
        RHSocketPacketResponse *ctx = [[RHSocketPacketResponse alloc] init];
        ctx.object = [frameData subdataWithRange:NSMakeRange(_countOfLengthByte, frameLen)];
        
        //责任链模式，丢给下一个处理器
        if (_nextDecoder) {
            [_nextDecoder decode:ctx output:output];
        } else {
            [output didDecode:ctx];
        }
        
        //调整已经解码数据
        headIndex += frameData.length;
    }//while
    return headIndex;
}

@end
