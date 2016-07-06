//
//  RHSocketConnection.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketConnectionDelegate.h"
#import "RHSocketConfig.h"

/**
 *  socket网络连接对象，只负责socket网络的连接通信，内部使用GCDAsyncSocket。
 *  1-只公开GCDAsyncSocket的主要方法，增加使用的便捷性。
 *  2-封装的另一个目的是，易于后续更新调整。如果不想使用GCDAsyncSocket，只想修改内部实现即可，对外不产生影响。
 */
@interface RHSocketConnection : NSObject <RHSocketConnectionDelegate>

@property (nonatomic, assign) BOOL useSecureConnection;
@property (nonatomic, strong) NSDictionary *tlsSettings;

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) int port;

- (instancetype)initWithHost:(NSString *)host port:(int)port;

@end
