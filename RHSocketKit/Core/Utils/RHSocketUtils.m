//
//  RHSocketUtils.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/23.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketUtils.h"

@implementation RHSocketUtils

+ (NSData *)byteFromUInt8:(uint8_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    
    return valData;
}

+ (NSData *)bytesFromUInt16:(uint16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    [valData appendBytes:valChar length:2];
    
    return valData;
}

+ (NSData *)bytesFromUInt32:(uint32_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    
    return valData;
}

+ (uint8_t)uint8FromBytes:(NSData *)data
{
    NSAssert(data.length == 1, @"uint8FromBytes: (data length != 1)");
    
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

+ (uint16_t)uint16FromBytes:(NSData *)data
{
    NSAssert(data.length == 2, @"uint16FromBytes: (data length != 2)");
    
    uint16_t val0 = 0;
    uint16_t val1 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    
    uint16_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00);
    return dstVal;
}

+ (uint32_t)uint32FromBytes:(NSData *)data
{
    NSAssert(data.length == 4, @"uint16FromBytes: (data length != 4)");
    
    uint32_t val0 = 0;
    uint32_t val1 = 0;
    uint32_t val2 = 0;
    uint32_t val3 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    [data getBytes:&val2 range:NSMakeRange(2, 1)];
    [data getBytes:&val3 range:NSMakeRange(3, 1)];
    
    uint32_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00) + ((val1 << 16) & 0xff0000) + ((val1 << 24) & 0xff000000);
    return dstVal;
}

@end
