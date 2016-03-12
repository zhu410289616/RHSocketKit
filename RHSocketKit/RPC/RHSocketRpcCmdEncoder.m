//
//  RHSocketRpcCmdEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/3/12.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketRpcCmdEncoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"

@implementation RHSocketRpcCmdEncoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    id object = [upstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
        return;
    }
    
    NSMutableData *dataObject = nil;
    
    if ([upstreamPacket respondsToSelector:@selector(pid)]) {
        NSInteger pid = [upstreamPacket pid];
        NSData *cmdData = [RHSocketUtils bytesFromValue:pid byteCount:4];
        dataObject = [NSMutableData dataWithData:cmdData];
    }
    [dataObject appendData:object];
    
    //责任链模式，丢给下一个处理器
    if (_nextEncoder) {
        [upstreamPacket setObject:dataObject];
        [_nextEncoder encode:upstreamPacket output:output];
        return;
    }
    
    [output didEncode:dataObject timeout:[upstreamPacket timeout]];
}

@end
