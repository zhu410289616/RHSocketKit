//
//  RHSocketVariableLengthCodec.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/17.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

/**
 *  可变长度编码解码器
 *  数据包的前两个字节为数据帧的总长度（总长度包含自身的2个字节, total=2+frame）
 *  解码时，读取前两个字节，得到单帧的数据长度，然后读区对应长度的数据帧
 */
@interface RHSocketVariableLengthCodec : NSObject <RHSocketCodecProtocol>

- (NSUInteger)frameLengthWithData:(NSData *)lenData;

@end
