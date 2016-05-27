//
//  RHProtobufVarint32LengthDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHProtobufVarint32LengthDecoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils+Protobuf.h"
#import "RHSocketPacketContext.h"

@implementation RHProtobufVarint32LengthDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = INT32_MAX;
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
    while (downstreamData && downstreamData.length - headIndex > 1) {
        
        NSRange remainRange = NSMakeRange(headIndex, downstreamData.length - headIndex);
        NSData *remainData = [downstreamData subdataWithRange:remainRange];
        
        NSInteger countOfLengthByte = [RHSocketUtils computeCountOfLengthByte:remainData];
        if (countOfLengthByte <= 0) {
            break;
        }
        
        NSData *lenData = [downstreamData subdataWithRange:NSMakeRange(headIndex, countOfLengthByte)];
        //长度字节数据，可能存在高低位互换，通过数值转换工具处理
        NSUInteger frameLen = (NSUInteger)[RHSocketUtils valueWithVarint32Data:lenData];
        if (frameLen >= _maxFrameSize - countOfLengthByte) {
            [RHSocketException raiseWithReason:@"[Decode] Too Long Frame ..."];
            return -1;
        }//
        
        //剩余数据，不是完整的数据包，则break继续读取等待
        if (downstreamData.length - headIndex < countOfLengthByte + frameLen) {
            break;
        }
        //数据包(长度＋内容)
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, countOfLengthByte + frameLen)];
        
        //去除数据长度后的数据内容
        RHSocketPacketResponse *ctx = [[RHSocketPacketResponse alloc] init];
        ctx.object = [frameData subdataWithRange:NSMakeRange(countOfLengthByte, frameLen)];
        
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
