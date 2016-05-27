//
//  RHProtobufVarint32LengthEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHProtobufVarint32LengthEncoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils+Protobuf.h"

@implementation RHProtobufVarint32LengthEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = INT32_MAX;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [upstreamPacket dataWithPacket];
    if (data.length == 0) {
        RHSocketLog(@"[Encode] object data is nil ...");
        return;
    }//
    
    if (data.length >= _maxFrameSize - 4) {
        [RHSocketException raiseWithReason:@"[Encode] Too Long Frame ..."];
        return;
    }//
    
    //可变长度编码，数据块的前两个字节为后续完整数据块的长度
    NSUInteger dataLen = data.length;
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //将数据长度转换为长度字节，写入到数据块中。这里根据head占的字节个数转换data长度，长度不定[1~5]
    NSData *headData = [RHSocketUtils dataWithRawVarint32:dataLen];
    [sendData appendData:headData];
    [sendData appendData:data];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

@end
