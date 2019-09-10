//
//  RHChannelBufferProtocol.h
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

//NS_ASSUME_NONNULL_BEGIN

@protocol RHUpstreamBuffer;
@protocol RHDownstreamBuffer;

@protocol RHUpstreamBufferDelegate <NSObject>

- (void)packetWillEncode:(NSMutableArray *)packets;
- (void)upstreamBufferOverflow:(id<RHUpstreamBuffer>)upstreamBuffer;

@end

@protocol RHDownstreamBufferDelegate <NSObject>

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
- (void)downstreamBufferOverflow:(id<RHDownstreamBuffer>)downstreamBuffer;

@optional

/**
 * 解码后剩余数据缓存块
 * bufferData：剩余数据块
 * decodedSize：本次解码数据块大小
 */
- (void)dataDidDecode:(NSInteger)remainDataSize;

@end

@protocol RHUpstreamBuffer <NSObject>

/** 缓存数据包个数，默认为30 */
@property (nonatomic, assign) NSUInteger maxPacketSize;
/** 缓存收到上行数据回调 */
@property (nonatomic,   weak) id<RHUpstreamBufferDelegate> delegate;
/** 上行数据写入缓存buffer */
- (void)appendSendPacket:(id<RHUpstreamPacket>)packet;
/** 返回缓存的数据包，同时清空缓存 */
- (NSArray *)packetsForFlush;

@end

@protocol RHDownstreamBuffer <NSObject>

/** 缓存数据块最大值，默认为8192 */
@property (nonatomic, assign) NSUInteger maxBufferSize;
/** 缓存收到下行数据回调 */
@property (nonatomic,   weak) id<RHDownstreamBufferDelegate> delegate;
/** 下行数据写入缓存buffer */
- (void)appendReceiveData:(NSData *)receiveData;

@end

//NS_ASSUME_NONNULL_END
