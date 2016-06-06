//
//  RHSocketCustomRequest.m
//  RHSocketCustomCodecDemo
//
//  Created by zhuruhong on 16/3/30.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketCustomRequest.h"

@implementation RHSocketCustomRequest

- (instancetype)init
{
    if (self = [super init]) {
        _fenGeFu = 0x24;
        _dataType = 0;
    }
    return self;
}

@end
