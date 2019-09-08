//
//  RHTcpServer.h
//  Pipeline
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface RHTcpServer : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic,   copy) NSString *tcpHost;
@property (nonatomic, assign) NSInteger tcpPort;

@property (nonatomic, strong, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong, readonly) NSMutableArray *connectedSockets;

- (void)startTcpServer;
- (void)stopTcpServer;

@end

NS_ASSUME_NONNULL_END
