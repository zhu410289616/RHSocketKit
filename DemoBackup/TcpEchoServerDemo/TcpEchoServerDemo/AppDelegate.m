//
//  AppDelegate.m
//  TcpEchoServerDemo
//
//  Created by zhuruhong on 16/6/8.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "RHSocketServerConnection.h"

@interface AppDelegate () <GCDAsyncSocketDelegate, RHSocketServerConnectionDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong, readonly) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong, readonly) NSMutableArray *connectedSockets;

@end

@implementation AppDelegate

- (instancetype)init
{
    if (self = [super init]) {
        
        //
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        
        //
        _socketQueue = dispatch_queue_create("socketQueue", NULL);
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    UInt16 port = 20162;
    
    NSError *error = nil;
    if (![_tcpSocket acceptOnPort:port error:&error]) {
        NSLog(@"Error starting tcp echo server: %@", error);
        return;
    }
    
    NSLog(@"Tcp echo server started on port %hu", [_tcpSocket localPort]);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    @synchronized(_connectedSockets) {
        RHSocketServerConnection *con = [[RHSocketServerConnection alloc] initWithAsyncSocket:newSocket configuration:self.socketQueue];
        con.delegate = self;
        [_connectedSockets addObject:con];
        [con start];
    }
}

#pragma mark - RHSocketServerConnectionDelegate

- (void)didDisconnect:(RHSocketServerConnection *)con withError:(NSError *)err
{
    @synchronized(_connectedSockets) {
        [_connectedSockets removeObject:con];
    }
}

@end
