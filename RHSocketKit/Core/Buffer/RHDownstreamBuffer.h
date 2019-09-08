//
//  RHDownstreamBuffer.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@protocol RHDownstreamBufferProtocol <NSObject>

/**
 * 解码前数据缓存块
 * bufferData：待解码数据块
 * return：已经解码数据块大小
 */
- (NSInteger)dataWillDecode:(NSData *)bufferData;

/**
 * 数据未被正常解码消费，缓冲区溢出
 * bufferData：当前缓冲区数据
 */
- (void)bufferOverflow:(NSData *)bufferData;

@optional

/**
 * 解码后剩余数据缓存块
 * bufferData：剩余数据块
 * decodedSize：本次解码数据块大小
 */
- (void)dataDidDecode:(NSInteger)remainDataSize;

@end

/**
 *  下行数据包缓存
 */
@interface RHDownstreamBuffer : NSObject

/** 缓存数据块最大值，默认为8192 */
@property (nonatomic, assign) NSUInteger maxBufferSize;
/** 缓存收到下行数据回调 */
@property (nonatomic,   weak) id<RHDownstreamBufferProtocol> delegate;
/** 下行数据写入缓存buffer */
- (void)appendReceiveData:(NSData *)receiveData;

@end

//NS_ASSUME_NONNULL_END
