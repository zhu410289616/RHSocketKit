//
//  RHSocketUdpConnection.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/2.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketUdpConnection.h"
#import "GCDAsyncUdpSocket.h"

@interface RHSocketUdpConnection () <GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *_udpSocket;
}

@end

@implementation RHSocketUdpConnection

- (instancetype)init
{
    if (self = [super init]) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
    _udpSocket.delegate = nil;
    _udpSocket = nil;
}

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
    NSError *error = nil;
    [_udpSocket connectToHost:hostName onPort:port error:&error];
    if (error) {
        NSLog(@"[RHSocketConnection] connectWithHost error: %@", error.description);
//        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
//            [_delegate didDisconnectWithError:error];
//        }
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{}

@end
