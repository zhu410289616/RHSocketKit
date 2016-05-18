//
//  RHSocketRpcCmdDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/3/12.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketRpcCmdDecoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"

@implementation RHSocketRpcCmdDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    id object = [downstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
        return -1;
    }
    
    NSData *dataObject = object;
    if ([downstreamPacket respondsToSelector:@selector(pid)]) {
        NSData *cmdData = [dataObject subdataWithRange:NSMakeRange(0, 4)];
        NSInteger pid = (NSInteger)[RHSocketUtils valueFromBytes:cmdData];
        [downstreamPacket setPid:pid];
        [downstreamPacket setObject:[dataObject subdataWithRange:NSMakeRange(4, dataObject.length - 4)]];
    }
    
    //责任链模式，丢给下一个处理器
    if (_nextDecoder) {
        return [_nextDecoder decode:downstreamPacket output:output];
    }
    
    [output didDecode:downstreamPacket];
    return 0;
}

@end
