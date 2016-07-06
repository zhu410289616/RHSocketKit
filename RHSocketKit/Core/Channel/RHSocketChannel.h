//
//  RHSocketChannel.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/15.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "RHSocketCodecProtocol.h"

@class RHSocketChannel;

@protocol RHSocketChannelDelegate <NSObject>

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port;
- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error;
- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet;

@end

/**
 *  在RHSocketConnection基础上做封装，负责对socket中的二进制通讯数据做缓存、编码、解码处理。
 *
 *  1-需要有一个编码解码器，对数据块做封包和解包。很多人不理解这个，其实很简单。
 *  比如一句话里面没有标点符号你怎么知道什么时候是结束什么时候开始呢
 *  2-内部带有一个数据缓存，用于对数据的拼包。
 *  发送网络数据时，一条数据会被切成多个网络包［不是我们上层协议中的概念］，需要对收到的数据做合并，完整后才能正常解码。
 */
@interface RHSocketChannel : RHSocketConnection

@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;

/**
 *  socket connection的回调代理，查看RHSocketConnectionDelegate
 */
@property (nonatomic, weak) id<RHSocketChannelDelegate> delegate;

//@property (nonatomic, copy) NSString *host;
//@property (nonatomic, assign) int port;
//
//- (instancetype)initWithHost:(NSString *)host port:(int)port;

- (void)openConnection;
- (void)closeConnection;

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet;

- (void)writeInt8:(int8_t)param;
- (void)writeInt16:(int16_t)param;
- (void)writeInt32:(int32_t)param;
- (void)writeInt64:(int64_t)param;

@end
