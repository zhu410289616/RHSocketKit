//
//  RHSocketUtils+Protobuf.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketUtils+Protobuf.h"

@implementation RHSocketUtils (Protobuf)

/**
 *  计算出一帧数据的长度字节个数 (1～5)
 *
 *  @param frameData 带解码字节
 *
 *  @return 返回一帧数据的长度字节个数, varint32, 返回值为1～5有效，－1为计算失败
 */
+ (NSInteger)computeCountOfLengthByte:(NSData *)frameData
{
    //默认长度字节个数为－1
    NSInteger countOfLengthByte = -1;
    //最大尝试读区个数为4个字节，超过则认为是大数据5个字节
    NSInteger maxCountOfLengthByte = MIN(frameData.length, 4);
    //从第1个字节开始尝试读取计算
    NSInteger testIndex = 0;
    
    while (testIndex < maxCountOfLengthByte) {
        NSRange lengthRange = NSMakeRange(testIndex, 1);
        NSData *oneByte = [frameData subdataWithRange:lengthRange];
        int8_t oneValue = [RHSocketUtils int8FromBytes:oneByte];
        
        if ((oneValue & 0x80) == 0) {
            countOfLengthByte = testIndex + 1;
            break;
        }
        testIndex++;//增加长度字节个数
    }//while
    
    //超过4个字节，则认为是大数据5个字节
    if (testIndex >= 4) {
        countOfLengthByte = 5;
    }
    return countOfLengthByte;
}

+ (int64_t)valueWithVarint32Data:(NSData *)data
{
    NSUInteger dataLen = data.length;
    int64_t value = 0;
    int offset = 0;
    
    while (offset < dataLen) {
        int32_t tempVal = 0;
        [data getBytes:&tempVal range:NSMakeRange(offset, 1)];
        tempVal = (tempVal & 0x7F);
        value += (tempVal << (7 * offset));
        offset++;
    }//while
    
    return value;
}

+ (NSData *)dataWithRawVarint32:(int64_t)value
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    while (true) {
        if ((value & ~0x7F) == 0) {//如果最高位是0，只要一个字节表示
            [valData appendBytes:&value length:1];
            break;
        } else {
            int valChar = (value & 0x7F) | 0x80;//先写入低7位，最高位置1
            [valData appendBytes:&valChar length:1];
             value = value >> 7;//再写高7位
        }
    }
    return valData;
}

@end
