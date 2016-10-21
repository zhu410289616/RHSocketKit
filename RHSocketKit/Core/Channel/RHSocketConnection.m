//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "GCDAsyncSocket.h"

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

- (void)didDisconnect:(id<RHSocketConnectionDelegate>)con withError:(NSError *)err
{
    //override
}

- (void)didConnect:(id<RHSocketConnectionDelegate>)con toHost:(NSString *)host port:(uint16_t)port
{
    //override
}

- (void)didRead:(id<RHSocketConnectionDelegate>)con withData:(NSData *)data tag:(long)tag
{
    //override
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
        [weakSelf.asyncSocket writeData:data withTimeout:timeout tag:tag];
    } async:YES];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    RHSocketLog(@"socketDidDisconnect: %@", err.description);
    [self didDisconnect:self withError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    RHSocketLog(@"didConnectToHost: %@, port: %d", host, port);
    
    if (self.connectParam.useSecureConnection) {
        RHSocketLog(@"_useSecureConnection: %i", self.connectParam.useSecureConnection);
        [sock startTLS:self.connectParam.tlsSettings];
        return;
    }
    
    [self didConnect:self toHost:host port:port];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    RHSocketLog(@"socketDidSecure...");
    [self didConnect:self toHost:sock.connectedHost port:sock.connectedPort];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    RHSocketLog(@"didReadData length: %lu, tag: %ld", (unsigned long)data.length, tag);
    [self didRead:self withData:data tag:tag];
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    RHSocketLog(@"didWriteDataWithTag: %ld", tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
