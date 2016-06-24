//
//  RHSocketConnection.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketConfig.h"

/**
 *  socket connection的回调代理协议
 */
@protocol RHSocketConnectionDelegate <NSObject>

/**
 *  和socket服务器 连接失败／断开连接 的回调方法
 *
 *  @param error 错误原因
 */
- (void)didDisconnectWithError:(NSError *)error;

/**
 *  和socket服务器连接成功的回调方法
 *
 *  @param host 连接成功的服务器地址ip
 *  @param port 连接成功的服务器端口port
 */
- (void)didConnectToHost:(NSString *)host port:(UInt16)port;

/**
 *  接收到从socket服务器推送下来的下行数据回调方法
 *
 *  @param data 推送过来的下行数据
 *  @param tag  数据tag标记，和readDataWithTimeout:tag/writeData:timeout:tag:中的tag对应。
 */
- (void)didReceiveData:(NSData *)data tag:(long)tag;

@end

/**
 *  socket网络连接对象，只负责socket网络的连接通信，内部使用GCDAsyncSocket。
 *  1-只公开GCDAsyncSocket的主要方法，增加使用的便捷性。
 *  2-封装的另一个目的是，易于后续更新调整。如果不想使用GCDAsyncSocket，只想修改内部实现即可，对外不产生影响。
 */
@interface RHSocketConnection : NSObject

@property (nonatomic, assign) BOOL useSecureConnection;
@property (nonatomic, strong) NSDictionary *tlsSettings;

/**
*  socket connection的回调代理，查看RHSocketConnectionDelegate
*/
@property (nonatomic, weak) id<RHSocketConnectionDelegate> delegate;

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
 *  接收数据方法，读取socket中的下行数据流。根据GCDAsyncSocket提供的方法，对外提供参数。
 *  该方法有tag标记，和写socket中的上行数据中的tag对应。如果希望针对某个tag写请求读取对应的返回数据，需要记录tag。
 *
 *  @param timeout 读取数据超时时间
 *  @param tag     读取数据tag标记，和writeData:timeout:tag:中的tag对应。
 */
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

/**
 *  发送数据方法，写socket的上行数据流。根据GCDAsyncSocket提供的方法，对外提供参数。
 *  该方法有tag标记，发送数据时，如果携带了某个特定的tag，则在read中的tag也必须对应，否则读取不到数据。
 *  发送数据后，一定要调用一次read，这样数据才会及时触发读取。
 *  我在didReadData和didWriteDataWithTag方法中都有加的read的，所以你们可以放心用啦。
 *  [有的朋友说，自己连接上服务器后一直读不到数据，就是因为没有read。]
 *
 *  @param data    待发送的数据块
 *  @param timeout 发送超时时间
 *  @param tag     发送的特定请求标记，和readDataWithTimeout:tag中的tag对应。
 */
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag;

@end
