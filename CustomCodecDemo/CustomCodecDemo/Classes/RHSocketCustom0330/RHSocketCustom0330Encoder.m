//
//  RHSocketCustom0330Encoder.m
//  RHSocketCustomCodecDemo
//
//  Created by zhuruhong on 16/3/30.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketCustom0330Encoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"
#import "RHSocketCustomRequest.h"
#import "RHSocketByteBuf.h"

@implementation RHSocketCustom0330Encoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    id object = [upstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:@"[Encode] object should be NSData ..."];
        return;
    }
    
    NSData *data = object;
    if (data.length == 0) {
        return;
    }//
    
    RHSocketCustomRequest *req = (RHSocketCustomRequest *)upstreamPacket;
    NSUInteger dataLen = data.length;
    
    RHSocketByteBuf *buffer = [[RHSocketByteBuf alloc] init];
    //分隔符 2个字节
    [buffer writeInt16:req.fenGeFu];
    //数据包类型 2个字节
    [buffer writeInt16:req.dataType];
    //长度（不含包头长度） 4个字节
    [buffer writeInt32:(uint32_t)dataLen];
    //数据包 dataLen个字节
    [buffer writeData:data];
    
//    NSMutableData *sendData = [[NSMutableData alloc] init];
//    //分隔符 2个字节
//    [sendData appendData:[RHSocketUtils bytesFromInt16:req.fenGeFu]];
//    //数据包类型 2个字节
//    [sendData appendData:[RHSocketUtils bytesFromInt16:req.dataType]];
//    //长度（不含包头长度） 4个字节
//    [sendData appendData:[RHSocketUtils bytesFromInt32:(uint32_t)dataLen]];
//    //数据包 dataLen个字节
//    [sendData appendData:data];
    
    NSTimeInterval timeout = [upstreamPacket timeout];
    
//    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
//    [output didEncode:sendData timeout:timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, [buffer data]);
    [output didEncode:[buffer data] timeout:timeout];
}

@end
