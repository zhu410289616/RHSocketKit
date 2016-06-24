//
//  RHSocketConnectionDelegate.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

/**
 *  socket connection的回调代理协议
 */
@protocol RHSocketConnectionDelegate <NSObject>

@required

/**
 *  触发连接socket服务器
 *
 *  @param hostName socket服务器ip或域名
 *  @param port     socket服务器端口port
 */
- (void)connectWithHost:(NSString *)hostName port:(int)port;

/**
 *  主动断开socket服务器连接
 */
- (void)disconnect;

/**
 *  和socket服务器的连接状态
 *
 *  @return 返回yes－连接，no－断开
 */
- (BOOL)isConnected;

/**
 *  和socket服务器 连接失败／断开连接 的回调方法
 *
 *  @param con 当前socket connection
 *  @param err 错误原因
 */
- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err;

/**
 *  和socket服务器连接成功的回调方法
 *
 *  @param con  当前socket connection
 *  @param host 连接成功的服务器地址ip
 *  @param port 连接成功的服务器端口port
 */
- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port;

/**
 *  接收到从socket服务器推送下来的下行数据(原始数据流)回调方法
 *
 *  @param con  当前socket connection
 *  @param data 推送过来的下行数据
 *  @param tag  数据tag标记，和readDataWithTimeout:tag/writeData:timeout:tag:中的tag对应。
 */
- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag;

@optional

/**
 *  接收数据方法，读取socket中的下行数据流。根据GCDAsyncSocket提供的方法，对外提供参数。
 *  该方法有tag标记，和写socket中的上行数据中的tag对应。如果希望针对某个tag写请求读取对应的返回数据，需要记录tag。
 *
 *  @param timeout 读取数据超时时间
 *  @param tag     读取数据tag标记，和writeData:timeout:tag:中的tag对应。
 */
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

/**
 *  发送数据方法，写socket的上行数据流。根据GCDAsyncSocket提供的方法，对外提供参数。
 *  该方法有tag标记，为了简化使用方式，框架中统一使用0。
 *  发送数据后，一定要调用一次read，这样数据才会及时触发读取。
 *  我在didReadData和didWriteDataWithTag方法中都有加的read的，所以你们可以放心用啦。
 *  [有的朋友说，自己连接上服务器后一直读不到数据，就是因为没有read。]
 *
 *  @param data    待发送的数据块
 *  @param timeout 发送超时时间
 *  @param tag     发送的特定请求标记，和readDataWithTimeout:tag中的tag对应。
 */
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag;

/**
 *  对原始数据流做拼包后得到的一个完整数据包
 *
 *  @param con    当前socket connection
 *  @param packet 下行数据拼包之后，解码得到的数据包
 */
- (void)didReceived:(id<RHSocketConnectionDelegate>)con withPacket:(id<RHDownstreamPacket>)packet;

@end
