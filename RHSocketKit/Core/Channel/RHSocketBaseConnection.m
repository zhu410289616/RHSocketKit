//
//  RHSocketBaseConnection.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketBaseConnection.h"
#import "GCDAsyncSocket.h"

@interface RHSocketBaseConnection () <GCDAsyncSocketDelegate>

@end

@implementation RHSocketBaseConnection

#pragma mark - RHSocketConnectionDelegate

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
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
}

- (void)disconnect
{
    if (nil == _asyncSocket) {
        return;
    }
    [_asyncSocket disconnect];
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
}

- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
}

- (void)didDisconnect:(RHSocketBaseConnection *)con withError:(NSError *)err
{
    //override
}

- (void)didConnect:(RHSocketBaseConnection *)con toHost:(NSString *)host port:(uint16_t)port
{
    //override
}

- (void)didRead:(RHSocketBaseConnection *)con withData:(NSData *)data tag:(long)tag
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
