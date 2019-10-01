//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "RHSocketMacros.h"
#import "GCDAsyncSocket.h"
#import "NSObject+RHExtends.h"
#import "NSMutableDictionary+RHExtends.h"

NSString * const RHSocketQueueSpecific = @"com.zrh.rhsocket.RHSocketQueueSpecific";

@interface RHSocketConnection () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, assign) void *IsOnSocketQueueOrTargetQueueKey;

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@end

@implementation RHSocketConnection

- (instancetype)initWithConnectParam:(RHSocketConnectParam *)connectParam
{
    if (self = [super init]) {
        //queue
        _socketQueue = dispatch_queue_create([RHSocketQueueSpecific UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _IsOnSocketQueueOrTargetQueueKey = &_IsOnSocketQueueOrTargetQueueKey;
        void *nonNullUnusedPointer = (__bridge void *)self;
        dispatch_queue_set_specific(_socketQueue, _IsOnSocketQueueOrTargetQueueKey, nonNullUnusedPointer, NULL);
        
        //connect param
        _connectParam = connectParam;
        
        [self injectInterceptor];
    }
    return self;
}

#pragma mark - queue

- (BOOL)isOnSocketQueue
{
    return dispatch_get_specific(_IsOnSocketQueueOrTargetQueueKey) != NULL;
}

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async
{
    if ([self isOnSocketQueue]) {
        @autoreleasepool {
            block();
        }
        return;
    }
    
    [self rh_dispatchOnQueue:[self socketQueue] block:block async:async];
}

#pragma mark - interceptor

- (void)injectInterceptor
{}

#pragma mark - RHSocketConnection protocol

- (void)connectWithParam:(RHSocketConnectParam *)connectParam
{
    NSAssert(connectParam.host.length > 0, @"host is nil");
    NSAssert(connectParam.port > 0, @"port is 0");
    
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        [weakSelf disconnect];
        
        weakSelf.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:weakSelf delegateQueue:weakSelf.socketQueue];
        [weakSelf.asyncSocket setIPv4PreferredOverIPv6:NO];
        
        NSError *error = nil;
        [weakSelf.asyncSocket connectToHost:connectParam.host onPort:connectParam.port withTimeout:connectParam.timeout error:&error];
        if (error) {
            [weakSelf didDisconnect:weakSelf withError:error];
        }
    } async:YES];
}

- (void)disconnect
{
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        if (nil == weakSelf.asyncSocket) {
            return;
        }
        [weakSelf.asyncSocket disconnect];
        weakSelf.asyncSocket.delegate = nil;
        weakSelf.asyncSocket = nil;
    } async:YES];
}

- (BOOL)isConnected
{
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        result = [weakSelf.asyncSocket isConnected];
    } async:NO];
    return result;
}

/** override */
- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    RHSocketLog(@"[Log]: socketDidDisconnect: %@", err.description);
}

/** override */
- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    RHSocketLog(@"[Log]: didConnectToHost: %@, port: %d", host, port);
}

/** override */
- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    RHSocketLog(@"[Log]: didReadData length: %lu, tag: %ld", (unsigned long)data.length, tag);
}

#pragma mark - read & write

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        [weakSelf.asyncSocket readDataWithTimeout:timeout tag:tag];
    } async:YES];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        //数据写入前拦截writeInterceptor
        NSData *theData = data;
        if ([self.writeInterceptor respondsToSelector:@selector(interceptor:userInfo:)]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo rh_setValueEx:@(tag) forKey:@"tag"];
            [userInfo rh_setValueEx:@(timeout) forKey:@"timeout"];
            theData = [self.readInterceptor interceptor:theData userInfo:userInfo];
        }
        
        [weakSelf.asyncSocket writeData:theData withTimeout:timeout tag:tag];
    } async:YES];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self didDisconnect:self withError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (self.connectParam.useSecureConnection) {
        RHSocketLog(@"[GCDAsyncSocket]: use secure connection");
        [sock startTLS:self.connectParam.tlsSettings];
        return;
    }
    
    [self didConnect:self toHost:host port:port];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    RHSocketLog(@"[GCDAsyncSocket]: socketDidSecure...");
    [self didConnect:self toHost:sock.connectedHost port:sock.connectedPort];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //读取到数据拦截readInterceptor
    NSData *theData = data;
    if ([self.readInterceptor respondsToSelector:@selector(interceptor:userInfo:)]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo rh_setValueEx:@(tag) forKey:@"tag"];
        [userInfo rh_setValueEx:sock forKey:@"sock"];
        theData = [self.readInterceptor interceptor:theData userInfo:userInfo];
    }
    [self didRead:self withData:theData tag:tag];
    
    //读取数据后，继续读取后面数据
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    RHSocketLog(@"[GCDAsyncSocket]: didWriteDataWithTag: %ld", tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
