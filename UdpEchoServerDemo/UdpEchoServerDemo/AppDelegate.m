//
//  AppDelegate.m
//  UdpEchoServerDemo
//
//  Created by zhuruhong on 16/6/8.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncUdpSocket.h"

@interface AppDelegate () <GCDAsyncUdpSocketDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong, readonly) GCDAsyncUdpSocket *udpSocket;

@end

@implementation AppDelegate

- (instancetype)init
{
    if (self = [super init]) {
        
        //
        _socketQueue = dispatch_queue_create("socketQueue", NULL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    UInt16 port = 20166;
    
    NSError *error = nil;
    if (![_udpSocket bindToPort:port error:&error]) {
        NSLog(@"Error starting udp echo server (bind): %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        [_udpSocket close];
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
    
    NSLog(@"Udp echo server started on port %hu", [_udpSocket localPort]);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"didReceiveData: [%@] - %@", address, data);
    
    // Echo message back to client
    [sock sendData:data toAddress:address withTimeout:-1 tag:0];
}

@end
