//
//  RHSocketTLSConnection.m
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketTLSConnection.h"

@implementation RHSocketTLSConnection

#pragma mark - RHSocketConnectionDelegate

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
    if (_useSecureConnection && (nil == _tlsSettings)) {
        // Configure SSL/TLS settings
        NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
        settings[(NSString *)kCFStreamSSLPeerName] = hostName;
        _tlsSettings= settings;
    }
    [super connectWithHost:hostName port:port];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (_useSecureConnection) {
        RHSocketLog(@"_useSecureConnection: %i, _tlsSettings: %@", _useSecureConnection, _tlsSettings);
        [sock startTLS:_tlsSettings];
        return;
    }
    
    [super socket:sock didConnectToHost:host port:port];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    RHSocketLog(@"socketDidSecure...");
    [self didConnect:self toHost:sock.connectedHost port:sock.connectedPort];
}

@end
