//
//  RHWebSocketAuthRequest.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHWebSocketAuthRequest.h"

@implementation RHWebSocketAuthRequest

- (instancetype)init
{
    if (self = [super init]) {
        NSString *req = [NSString stringWithFormat:
                         @"%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n",
                         @"GET / HTTP/1.1",
                         @"Host: 115.29.193.48:8088",
                         @"Upgrade: websocket",
                         @"Connection: Upgrade",
                         @"Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==",
                         @"Origin: http://www.blue-zero.com",
                         @"Sec-WebSocket-Protocol: chat, superchat",
                         @"Sec-WebSocket-Version: 13"
                         ];
        self.object = [req dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

@end
