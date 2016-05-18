//
//  RHSocketDelimiterDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterDecoder.h"
#import "RHSocketUtils.h"
#import "RHSocketException.h"
#import "RHSocketPacketContext.h"

@implementation RHSocketDelimiterDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _delimiterData = [RHSocketUtils CRLFData];
        _maxFrameSize = 8192;
    }
    return self;
}

- (instancetype)initWithDelimiter:(uint8_t)aDelimiter maxFrameSize:(NSUInteger)aMaxFrameSize
{
    if (self = [super init]) {
        _delimiterData = [NSData dataWithBytes:&aDelimiter length:1];
        _maxFrameSize = aMaxFrameSize;
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
    NSUInteger dataLen = downstreamData.length;
    NSUInteger headIndex = 0;
    
    while (YES) {
        //遍历数据的最大允许长度后，返回异常长度－1，进入channel的断开退出逻辑
        if (dataLen >= _maxFrameSize - 1) {
            [RHSocketException raiseWithReason:@"[Decode] Too Long Frame ..."];
            return -1;
        }
        //根据分隔符，获取一块数据包，类似得到一句完整的句子。然后output，触发上层逻辑
        NSRange range = NSMakeRange(headIndex, dataLen - headIndex);
        NSRange resultRange = [downstreamData rangeOfData:_delimiterData options:0 range:range];
        if (resultRange.length == 0) {
            break;
        }
        
        //去除分隔符后的数据包
        NSInteger frameLen = resultRange.location - headIndex;
        NSData *frameData = [downstreamData subdataWithRange:NSMakeRange(headIndex, frameLen)];
        
        RHSocketPacketResponse *ctx = [[RHSocketPacketResponse alloc] init];
        ctx.object = frameData;
        
        //责任链模式，丢给下一个处理器
        if (_nextDecoder) {
            [_nextDecoder decode:ctx output:output];
        } else {
            [output didDecode:ctx];
        }
        
        //
        headIndex = resultRange.location + resultRange.length;
    }//while
    return headIndex;
}

@end
