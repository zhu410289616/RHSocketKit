//
//  RHWebSocketConfig.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/18.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHWebSocketConfig.h"

@implementation RHWebSocketConfig

- (instancetype)init
{
    if (self = [super init]) {
        _host = @"115.29.193.48";
        _port = 8088;
        _timeout = 30;//second
    }
    return self;
}

- (NSData *)dataWithHandshake
{
    NSString *req = [NSString stringWithFormat:
                     @"%@\r\n%@%@:%d\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n\r\n",
                     @"GET / HTTP/1.1",
                     @"Host: ", _host, _port,
                     @"Upgrade: websocket",
                     @"Connection: Upgrade",
                     @"Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==",
                     @"Sec-WebSocket-Protocol: chat, superchat",
                     @"Sec-WebSocket-Version: 13"
                     ];
    return [req dataUsingEncoding:NSUTF8StringEncoding];
}

@end
