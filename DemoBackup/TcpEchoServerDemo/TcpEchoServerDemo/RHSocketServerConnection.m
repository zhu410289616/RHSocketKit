//
//  RHSocketServerConnection.m
//  TcpEchoServerDemo
//
//  Created by zhuruhong on 16/9/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketServerConnection.h"
#import "GCDAsyncSocket.h"

@interface RHSocketServerConnection ()

@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@end

@implementation RHSocketServerConnection

- (void)dealloc
{
    [_asyncSocket setDelegate:nil delegateQueue:NULL];
    [_asyncSocket disconnect];
}

- (instancetype)initWithAsyncSocket:(GCDAsyncSocket *)aSocket configuration:(id)aConfig
{
    if (self = [super init]) {
        _socketQueue = aConfig;
        _asyncSocket = aSocket;
        [_asyncSocket setDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

- (void)start
{
    NSString *host = [self.asyncSocket connectedHost];
    UInt16 port = [self.asyncSocket connectedPort];
    NSLog(@"RHSocketServerConnection start %@:%hu", host, port);
    
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        [weakSelf.asyncSocket readDataWithTimeout:-1 tag:0];
    } async:YES];
}

- (void)stop
{
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        [weakSelf.asyncSocket disconnect];
    } async:YES];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSString *host = [self.asyncSocket connectedHost];
    UInt16 port = [self.asyncSocket connectedPort];
    NSLog(@"[%@:%hu] socketDidDisconnect: %@", host, port, err.description);
    [self.delegate didDisconnect:self withError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *host = [self.asyncSocket connectedHost];
    UInt16 port = [self.asyncSocket connectedPort];
    NSLog(@"[%@:%hu] didReadData length: %lu, tag: %ld", host, port, (unsigned long)data.length, tag);
    // Echo message back to client
    [sock writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSString *host = [self.asyncSocket connectedHost];
    UInt16 port = [self.asyncSocket connectedPort];
    NSLog(@"[%@:%hu] didWriteDataWithTag: %ld", host, port, tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    //read time 15 second
    if (elapsed <= 15.0) {
        return 0.0;
    }
    
    return 0.0;
}

#pragma mark - queue

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async
{
    if (async) {
        dispatch_async([self socketQueue], ^{
            @autoreleasepool {
                block();
            }
        });
        return;
    }
    
    dispatch_sync([self socketQueue], ^{
        @autoreleasepool {
            block();
        }
    });
}

@end
