//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"

@implementation RHSocketConnection

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super init]) {
        _host = host;
        _port = port;
    }
    return self;
}

- (void)openConnection
{
    @synchronized(self) {
        [self closeConnection];
        [self connectWithHost:self.host port:self.port];
    }//@synchronized
}

- (void)closeConnection
{
    @synchronized(self) {
        [self disconnect];
    }//synchronized
}

@end
