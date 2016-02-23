//
//  AppDelegate.m
//  RHSocketServerDemo
//
//  Created by zhuruhong on 16/2/23.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

#define RHLogLog(format, ...) NSLog(format, ## __VA_ARGS__)

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@interface AppDelegate () <GCDAsyncSocketDelegate>
{
    dispatch_queue_t _socketQueue;
    
    GCDAsyncSocket *_listenSocket;
    NSMutableArray *_connectedSockets;
    
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (instancetype)init
{
    if (self = [super init]) {
        
        //
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        
        //
        _socketQueue = dispatch_queue_create("socketQueue", NULL);
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    UInt16 port = 20162;
    
    NSError *error = nil;
    if (![_listenSocket acceptOnPort:port error:&error]) {
        RHLogLog(@"Error starting server: %@", error);
        return;
    }
    
    RHLogLog(@"Echo server started on port %hu", [_listenSocket localPort]);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    @synchronized(_connectedSockets) {
        [_connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    RHLogLog(@"Accepted client %@:%hu", host, port);
    
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    RHLogLog(@"didReadData: [%ld] - %@", tag, data);
    
    // Echo message back to client
    [sock writeData:data withTimeout:-1 tag:0];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT) {
        return 0.0;
    }
    
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != _listenSocket) {
        RHLogLog(@"Client Disconnected");
        @synchronized(_connectedSockets) {
            [_connectedSockets removeObject:sock];
        }
    }
}

@end
