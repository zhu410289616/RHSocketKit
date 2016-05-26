//
//  RHSocketUtils+Protobuf.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketUtils.h"

@interface RHSocketUtils (Protobuf)

/**
 *  计算出一帧数据的长度字节个数 (1～5)
 *
 *  @param frameData 带解码字节
 *
 *  @return 返回一帧数据的长度字节个数, varint32, 返回值为1～5有效，－1为计算失败
 */
+ (NSInteger)computeCountOfLengthByte:(NSData *)frameData;

+ (int64_t)valueWithVarint32Data:(NSData *)data;
+ (NSData *)dataWithRawVarint32:(int64_t)value;

@end
