//
//  RHSocketCodecProtocol.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/16.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

#pragma mark - encoder output protocol

/**
 *  数据编码后，分发对象协议
 */
@protocol RHSocketEncoderOutputProtocol <NSObject>

@required

- (void)didEncode:(NSData *)encodedData timeout:(NSTimeInterval)timeout;

@end

#pragma mark - decoder output protocol

/**
 *  数据解码后，分发对象协议
 */
@protocol RHSocketDecoderOutputProtocol <NSObject>

@required

- (void)didDecode:(id<RHDownstreamPacket>)decodedPacket;

@end

#pragma mark - codec protocol

/**
 *  编码解码器协议
 */
@protocol RHSocketCodecProtocol <NSObject>

@required

/**
 *  编码器
 *
 *  @param packet 待发送的数据包
 *  @param output 数据编码后，分发对象
 */
- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output;

/**
 *  解码器
 *
 *  @param data   接收到的原始数据
 *  @param output 数据解码后，分发对象
 *
 *  @return -1解码异常，断开连接; 0数据不完整，等待数据包; >0解码正常，为已解码数据长度
 */
- (NSInteger)decode:(NSData *)downstreamData output:(id<RHSocketDecoderOutputProtocol>)output;

@end
