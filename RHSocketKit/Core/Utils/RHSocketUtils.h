//
//  RHSocketUtils.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/23.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSocketUtils : NSObject

/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
+ (NSData *)dataWithReverse:(NSData *)srcData;

/** 将数值转成字节。编码方式：低位在前，高位在后 */
+ (NSData *)byteFromUInt8:(uint8_t)val;
+ (NSData *)bytesFromUInt16:(uint16_t)val;
+ (NSData *)bytesFromUInt32:(uint32_t)val;
+ (NSData *)bytesFromValue:(NSUInteger)value byteCount:(int)byteCount;
+ (NSData *)bytesFromValue:(NSUInteger)value byteCount:(int)byteCount reverse:(BOOL)reverse;

/** 将字节转成数值。解码方式：前序字节为低位，后续字节为高位 */
+ (uint8_t)uint8FromBytes:(NSData *)data;
+ (uint16_t)uint16FromBytes:(NSData *)data;
+ (uint32_t)uint32FromBytes:(NSData *)data;
+ (NSUInteger)valueFromBytes:(NSData *)data;
+ (NSUInteger)valueFromBytes:(NSData *)data reverse:(BOOL)reverse;

/*** 16进制字符串转换为data。24211D3498FF62AF  -->  <24211D34 98FF62AF> */
+ (NSData *)dataFromHexString:(NSString *)hexString;

/** data转换为16进制。<24211D34 98FF62AF>  -->  24211D3498FF62AF */
+ (NSString *)hexStringFromData:(NSData *)data;

/** hex字符串转换为ascii码。00de0f1a8b24211D3498FF62AF -->  3030646530663161386232343231314433343938464636324146 */
+ (NSString *)asciiStringFromHexString:(NSString *)hexString;

/** ascii码转换为hex字符串。343938464636324146 --> 498FF62AF */
+ (NSString *)hexStringFromASCIIString:(NSString *)asciiString;

@end
