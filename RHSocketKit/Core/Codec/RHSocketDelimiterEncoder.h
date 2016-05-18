//
//  RHSocketDelimiterEncoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

/**
 *  分隔符编码器
 *  默认数据包每帧分隔符为\r\n（delimiterData == \r\n）
 *  默认数据包中每帧最大值为8192（maxFrameSize == 8192）
 *
 *  对应netty的DelimiterBasedFrameDecoder(8192, Delimiters.lineDelimiter())解码器
 */
@interface RHSocketDelimiterEncoder : NSObject <RHSocketEncoderProtocol>

/**
 *  应用协议中每帧数据之间的标记分隔符号
 *  比如一句话里面没有标点符号你怎么知道什么时候是结束什么时候开始呢
 *  在底层的二进制通讯中，这个分隔符就是最简单的协议标记
 */
@property (nonatomic, strong) NSData *delimiterData;

/**
 *  应用协议中允许发送的最大数据块大小，默认为8192
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

- (instancetype)initWithDelimiter:(uint8_t)aDelimiter maxFrameSize:(NSUInteger)aMaxFrameSize;

@end
