//
//  RHSocketVariableLengthDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

/**
 *  可变长度编码器
 *  数据包的前两个字节为数据帧内容的长度（总长度＝包头［2个字节］＋内容［length］，total=2+frameLength）
 *  解码时，读取前两个字节，得到单帧的数据长度，然后读区对应长度的数据帧
 *
 *  对应netty的LengthFieldBasedFrameDecoder(65536, 0, 2)解码器
 */
@interface RHSocketVariableLengthDecoder : NSObject <RHSocketDecoderProtocol>

/**
 *  应用协议中允许发送的最大数据块大小，默认为65536
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

/**
 *  包长度数据的字节个数，默认为2
 */
@property (nonatomic, assign) int countOfLengthByte;

/**
 *  包长度数据的字节顺序是否需要反向倒序处理，默认为YES
 */
@property (nonatomic, assign) BOOL reverseOfLengthByte;

@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;

@end
