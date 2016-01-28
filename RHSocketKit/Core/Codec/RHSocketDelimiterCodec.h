//
//  RHSocketDelimiterCodec.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/17.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

/**
 *  针对数据包分隔符编码解码器
 *  默认数据包中每帧最大值为8192（maxFrameSize == 8192）
 *  默认数据包每帧分隔符为0xff（delimiter == 0xff）
 *
 *  对应netty的DelimiterBasedFrameDecoder(8192, Delimiters.lineDelimiter())解码器
 */
@interface RHSocketDelimiterCodec : NSObject <RHSocketCodecProtocol>

/**
 *  应用协议中允许发送的最大数据块大小，默认为8192
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

/**
 *  应用协议中每帧数据之间的标记分隔符号
 *  比如一句话里面没有标点符号你怎么知道什么时候是结束什么时候开始呢
 *  在底层的二进制通讯中，这个分隔符就是最简单的协议标记
 */
@property (nonatomic, assign) uint8_t delimiter;

@end
