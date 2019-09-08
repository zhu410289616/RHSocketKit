//
//  RHTcpServer.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHTcpServer.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface RHTcpServer ()


@end

@implementation RHTcpServer

- (instancetype)init
{
    if (self = [super init]) {
        _tcpHost = @"127.0.0.1";
        _tcpPort = 4522;
        NSString *queueName = [NSString stringWithFormat:@"socketQueue.%@", [self class]];
        _socketQueue = dispatch_queue_create([queueName UTF8String], NULL);
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)startTcpServer
{
    NSError *error = nil;
    if (![_tcpSocket acceptOnPort:_tcpPort error:&error]) {
        NSLog(@"Error starting tcp echo server: %@", error);
        return;
    }
    
    NSDictionary *ipDic = [RHTcpServer getBothIPAddresses];
    NSString *wireless = ipDic[@"wireless"];
    NSString *cell = ipDic[@"cell"];
    
    _tcpHost = wireless.length > 0 ? wireless : cell;
    NSLog(@"Tcp echo server started on %@:%hu", _tcpHost, [_tcpSocket localPort]);
}

- (void)stopTcpServer
{
    [_tcpSocket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    @synchronized(_connectedSockets) {
        [_connectedSockets addObject:newSocket];
        newSocket.delegate = self;
        [newSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    @synchronized (_connectedSockets) {
        [_connectedSockets removeObject:sock];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *host = [sock connectedHost];
    UInt16 port = [sock connectedPort];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[%@:%hu] didReadData length: %lu, msg: %@", host, port, (unsigned long)data.length, msg);
    // Echo message back to client
    [sock writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSString *host = [sock connectedHost];
    UInt16 port = [sock connectedPort];
    NSLog(@"[%@:%hu] didWriteDataWithTag: %ld", host, port, tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark - ip address

+ (NSDictionary *)getBothIPAddresses
{
    const NSString *WIFI_IF = @"en0";
    NSArray *KNOWN_WIRED_IFS = @[@"en2",@"en3",@"en4"];
    NSArray *KNOWN_CELL_IFS = @[@"pdp_ip0",@"pdp_ip1",@"pdp_ip2",@"pdp_ip3"];
    
    const NSString *UNKNOWN_IP_ADDRESS = @"";
    
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithDictionary:@{@"wireless":UNKNOWN_IP_ADDRESS,
                                                                                     @"wired":UNKNOWN_IP_ADDRESS,
                                                                                     @"cell":UNKNOWN_IP_ADDRESS}];
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if (temp_addr->ifa_addr == NULL) {
                continue;
            }
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:WIFI_IF]) {
                    // Get NSString from C String
                    [addresses setObject:[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)] forKey:@"wireless"];
                    
                }
                // Check if interface is a wired connection
                if([KNOWN_WIRED_IFS containsObject:[NSString stringWithUTF8String:temp_addr->ifa_name]]) {
                    [addresses setObject:[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)] forKey:@"wired"];
                }
                // Check if interface is a cellular connection
                if([KNOWN_CELL_IFS containsObject:[NSString stringWithUTF8String:temp_addr->ifa_name]]) {
                    [addresses setObject:[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)] forKey:@"cell"];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return addresses;
}

@end
