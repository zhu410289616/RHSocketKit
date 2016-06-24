//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "RHSocketUtils.h"

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

- (void)writeInt8:(int8_t)param
{
    NSData *data = [RHSocketUtils byteFromInt8:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt16:(int16_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt16:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt32:(int32_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt32:param];
    [self writeData:data timeout:-1 tag:0];
}

- (void)writeInt64:(int64_t)param
{
    NSData *data = [RHSocketUtils bytesFromInt64:param];
    [self writeData:data timeout:-1 tag:0];
}

@end
