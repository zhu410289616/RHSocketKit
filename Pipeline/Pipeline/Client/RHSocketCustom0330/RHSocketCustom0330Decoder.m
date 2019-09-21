//
//  RHSocketCustom0330Decoder.m
//  RHSocketCustomCodecDemo
//
//  Created by zhuruhong on 16/3/30.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketCustom0330Decoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"
#import "RHSocketCustomResponse.h"

@interface RHSocketCustom0330Decoder ()
{
    NSUInteger _countOfLengthByte;
}

@end

@implementation RHSocketCustom0330Decoder

- (instancetype)init
{
    if (self = [super init]) {
        _countOfLengthByte = 8;
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
    
    while (downstreamData && downstreamData.length - headIndex >= _countOfLengthByte) {
        NSData *headData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _countOfLengthByte)];
        //去第4个字节开始的4个字节长度
        NSData *lenData = [headData subdataWithRange:NSMakeRange(4, 4)];
        //长度字节数据，可能存在高低位互换，通过数值转换工具处理
        NSUInteger frameLen = [RHSocketUtils int32FromBytes:lenData];
        
        //剩余数据，不是完整的数据包，则break继续读取等待
        if (downstreamData.length - headIndex < _countOfLengthByte + frameLen) {
            break;
        }
        //数据包(长度＋内容)
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, _countOfLengthByte + frameLen)];
        
        //去除数据长度后的数据内容
        RHSocketCustomResponse *rsp = [[RHSocketCustomResponse alloc] init];
        rsp.fenGeFu = [RHSocketUtils int16FromBytes:[headData subdataWithRange:NSMakeRange(0, 2)]];
        rsp.dataType = [RHSocketUtils int16FromBytes:[headData subdataWithRange:NSMakeRange(2, 2)]];
        rsp.object = [frameData subdataWithRange:NSMakeRange(_countOfLengthByte, frameLen)];
        
        [output didDecode:rsp];
        
        //调整已经解码数据
        headIndex += frameData.length;
    }//while
    return headIndex;
}

@end
