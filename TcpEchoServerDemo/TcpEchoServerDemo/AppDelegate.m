//
//  AppDelegate.m
//  TcpEchoServerDemo
//
//  Created by zhuruhong on 16/6/8.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@interface AppDelegate () <GCDAsyncSocketDelegate>

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
        [_connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    NSLog(@"Accepted client %@:%hu", host, port);
    
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData: [%ld] - %@", tag, data);
    
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
    if (sock != _tcpSocket) {
        NSLog(@"Client Disconnected");
        @synchronized(_connectedSockets) {
            [_connectedSockets removeObject:sock];
        }
    }
}

@end
