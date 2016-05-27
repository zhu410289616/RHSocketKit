//
//  RHProtobufVarint32LengthDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

/**
 *  protobuf解码器
 *  头部为［1～5］个字节的长度字段，后面紧跟protobuf的压缩数据
 *
 *  对应netty的pipeline.addLast("frameDecoder", new ProtobufVarint32FrameDecoder());解码器
 */
@interface RHProtobufVarint32LengthDecoder : NSObject <RHSocketDecoderProtocol>

/**
 *  应用协议中允许发送的最大数据块大小，默认为2147483647
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;

@end
