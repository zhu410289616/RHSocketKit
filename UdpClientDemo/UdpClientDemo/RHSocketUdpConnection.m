//
//  RHSocketUdpConnection.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/2.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketUdpConnection.h"
#import "GCDAsyncUdpSocket.h"
#import "RHSocketConfig.h"

@interface RHSocketUdpConnection () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong, readonly) dispatch_queue_t udpSocketQueue;
@property (nonatomic, strong, readonly) GCDAsyncUdpSocket *udpSocket;

@end

@implementation RHSocketUdpConnection

- (instancetype)init
{
    if (self = [super init]) {
        _udpSocketQueue = dispatch_queue_create("com.zrh.socket.udp.queue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpSocketQueue];
    }
    return self;
}

- (void)dealloc
{
    _udpSocket.delegate = nil;
    _udpSocket = nil;
}

- (void)setupUdpSocket
{
    NSError *error = nil;
    if (![_udpSocket bindToPort:0 error:&error]) {
        RHSocketLog(@"Error binding: %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        RHSocketLog(@"Error receiving: %@", error);
        return;
    }
    
    RHSocketLog(@"setupUdpSocket Ready");
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port
{
    long tag = clock();
    [self sendData:data toHost:host port:port tag:tag];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port tag:(long)tag
{
    [_udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
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
{
    // You could add checks here
    RHSocketLog(@"didSendDataWithTag[%ld]", tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    RHSocketLog(@"didNotSendDataWithTag[%ld]: %@", tag, error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    RHSocketLog(@"RECV: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    RHSocketLog(@"error: %@", error);
}

@end
