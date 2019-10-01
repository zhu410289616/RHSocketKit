//
//  RHChannelBufferProtocol.h
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

//NS_ASSUME_NONNULL_BEGIN

//======================================
// 上行数据包缓存协议
//======================================
#pragma mark - RHUpstreamBuffer

@protocol RHUpstreamBuffer;

typedef void(^RHUpstreamBufferEncode)(NSMutableArray *packets);
typedef void(^RHUpstreamBufferOverflow)(id<RHUpstreamBuffer> upstreamBuffer);

@protocol RHUpstreamBuffer <NSObject>

@required

/** 上行数据包缓存 */
@property (nonatomic, strong) NSMutableArray *packetBuffer;
/** 缓存数据包个数，默认为30 */
@property (nonatomic, assign) NSUInteger maxPacketSize;
/** 上行数据写入缓存buffer */
- (void)appendSendPacket:(id<RHUpstreamPacket>)packet
                  encode:(RHUpstreamBufferEncode)encodeCallback
                overflow:(RHUpstreamBufferOverflow)overflowCallback;
/** 返回缓存的数据包，同时清空缓存 */
- (NSArray *)packetsForFlush;

@end


//======================================
// 下行数据缓存协议
//======================================
#pragma mark - RHDownstreamBuffer

@protocol RHDownstreamBuffer;

/**
 * bufferData：待解码数据块
 * return：返回已经解码数据块大小
 */
typedef NSInteger(^RHDownstreamBufferDecode)(NSData *bufferData);
/**
 * 数据未被正常解码消费，缓冲区溢出
 * downstreamBuffer：当前缓冲区对象
 */
typedef void(^RHDownstreamBufferOverflow)(id<RHDownstreamBuffer> downstreamBuffer);

@protocol RHDownstreamBuffer <NSObject>

@required

/** 下行数据缓存 */
@property (nonatomic, strong) NSMutableData *dataBuffer;
/** 缓存数据块最大值，默认为8192 */
@property (nonatomic, assign) NSUInteger maxBufferSize;
/** 下行数据写入缓存buffer */
- (void)appendReceiveData:(NSData *)receiveData
                   decode:(RHDownstreamBufferDecode)decodeCallback
                 overflow:(RHDownstreamBufferOverflow)overflowCallback;

@optional

/** 解码后的数据包，可以再次处理数据包的持久化缓存和状态更新 */
- (void)decodedPakcet:(id<RHDownstreamPacket>)packet;

@end

//NS_ASSUME_NONNULL_END
