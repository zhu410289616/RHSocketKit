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

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super init]) {
        //queue
        _socketQueue = dispatch_queue_create([RHSocketQueueSpecific UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _IsOnSocketQueueOrTargetQueueKey = &_IsOnSocketQueueOrTargetQueueKey;
        void *nonNullUnusedPointer = (__bridge void *)self;
        dispatch_queue_set_specific(_socketQueue, _IsOnSocketQueueOrTargetQueueKey, nonNullUnusedPointer, NULL);
        
        //
        _host = host;
        _port = port;
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

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
    [self dispatchOnSocketQueue:^{
        [self disconnect];
        
        if (self.useSecureConnection && (nil == self.tlsSettings)) {
            // Configure SSL/TLS settings
            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
            settings[(NSString *)kCFStreamSSLPeerName] = hostName;
            self.tlsSettings= settings;
        }
        
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        [self.asyncSocket setIPv4PreferredOverIPv6:NO];
        
        NSError *err = nil;
        [self.asyncSocket connectToHost:hostName onPort:port error:&err];
        if (err) {
            [self didDisconnect:self withError:err];
        }
    } async:YES];
}

- (void)disconnect
{
    [self dispatchOnSocketQueue:^{
        if (nil == self.asyncSocket) {
            return;
        }
        [self.asyncSocket disconnect];
        self.asyncSocket.delegate = nil;
        self.asyncSocket = nil;
    } async:YES];
}

- (BOOL)isConnected
{
    __block BOOL result = NO;
    [self dispatchOnSocketQueue:^{
        result = [self.asyncSocket isConnected];
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
    [self dispatchOnSocketQueue:^{
        [self.asyncSocket readDataWithTimeout:timeout tag:tag];
    } async:YES];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self dispatchOnSocketQueue:^{
        [self.asyncSocket writeData:data withTimeout:timeout tag:tag];
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
    
    if (_useSecureConnection) {
        RHSocketLog(@"_useSecureConnection: %i, _tlsSettings: %@", _useSecureConnection, _tlsSettings);
        [sock startTLS:_tlsSettings];
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
