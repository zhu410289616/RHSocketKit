//
//  RHSocketConnectParam.h
//  Example
//
//  Created by zhuruhong on 16/8/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSocketConnectParam : NSObject

/**
 *  是否使用安全连接，默认为NO
 */
@property (nonatomic, assign) BOOL useSecureConnection;

/**
 *  安全连接的tls配置参数
 */
@property (nonatomic, strong) NSDictionary *tlsSettings;

/**
 *  连接服务器的domain或ip
 */
@property (nonatomic, copy) NSString *host;

/**
 *  连接服务器的端口
 */
@property (nonatomic, assign) int port;

/**
 *  连接服务器的超时时间（单位秒s），默认为15秒
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 *  连接后是否自动开启心跳，默认为YES
 */
@property (nonatomic, assign) BOOL heartbeatEnabled;

/**
 *  心跳定时间隔，默认为20秒
 */
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;

/**
 *  断开连接后，是否自动重连，默认为NO
 */
@property (nonatomic, assign) BOOL autoReconnect;

@end
