//
//  RHSocketVariableLengthEncoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketEncoderProtocol.h"

/**
 *  可变长度编码器
 *  数据包的前两个字节为数据帧的总长度（总长度包含自身的2个字节, total=2+frame）
 *  编码时计算被发送数据包的长度，然后将长度添加到数据帧的最前面
 */
@interface RHSocketVariableLengthEncoder : NSObject <RHSocketEncoderProtocol>

@end
