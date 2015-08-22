//
//  RHSocketVariableLengthDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketDecoderProtocol.h"

extern int const kProtocolFrameLengthOfHead;//默认为2

/**
 *  可变长度解码器
 *  数据包的前两个字节为数据帧的总长度（总长度包含自身的2个字节, total=2+frame）
 *  解码时，读取前两个字节，得到单帧的数据长度，然后读区对应长度的数据帧
 */
@interface RHSocketVariableLengthDecoder : NSObject <RHSocketDecoderProtocol>

- (NSUInteger)frameLengthWithData:(NSData *)lenData;

@end
