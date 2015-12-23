//
//  RHSocketUtils.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/23.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSocketUtils : NSObject

/** 将数值转成字节。编码方式：低位在前，高位在后 */
+ (NSData *)byteFromUInt8:(uint8_t)val;
+ (NSData *)bytesFromUInt16:(uint16_t)val;
+ (NSData *)bytesFromUInt32:(uint32_t)val;

/** 将字节转成数值。解码方式：前序字节为低位，后续字节为高位 */
+ (uint8_t)uint8FromBytes:(NSData *)data;
+ (uint16_t)uint16FromBytes:(NSData *)data;
+ (uint32_t)uint32FromBytes:(NSData *)data;

@end
