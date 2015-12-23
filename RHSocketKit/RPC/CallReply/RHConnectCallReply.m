//
//  RHConnectCallReply.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/22.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHConnectCallReply.h"

@implementation RHConnectCallReply

- (instancetype)init
{
    if (self = [super init]) {
        _host = @"127.0.0.1";
        _port = 7878;
    }
    return self;
}

@end
