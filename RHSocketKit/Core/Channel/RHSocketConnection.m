//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "GCDAsyncSocket.h"

@interface RHSocketConnection () <GCDAsyncSocketDelegate>

@property (nonatomic, strong, readonly) GCDAsyncSocket *asyncSocket;

@end

@implementation RHSocketConnection

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super init]) {
        _host = host;
        _port = port;
    }
    return self;
}

#pragma mark - RHSocketConnectionDelegate

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
    @synchronized (self) {
        [self disconnect];
        
        if (_useSecureConnection && (nil == _tlsSettings)) {
            // Configure SSL/TLS settings
            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
            settings[(NSString *)kCFStreamSSLPeerName] = hostName;
            _tlsSettings= settings;
        }
        
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_asyncSocket setIPv4PreferredOverIPv6:NO];
        
        NSError *err = nil;
        [_asyncSocket connectToHost:hostName onPort:port error:&err];
        if (err) {
            [self didDisconnect:self withError:err];
        }
    }//@synchronized
}

- (void)disconnect
{
    @synchronized (self) {
        if (nil == _asyncSocket) {
            return;
        }
        [_asyncSocket disconnect];
        _asyncSocket.delegate = nil;
        _asyncSocket = nil;
    }//@synchronized
}

- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
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
    [self.asyncSocket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self.asyncSocket writeData:data withTimeout:timeout tag:tag];
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
