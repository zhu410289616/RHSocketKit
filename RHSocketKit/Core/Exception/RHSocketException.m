//
//  RHSocketException.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/1.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketException.h"

NSString *const kRHSocketException = @"kRHSocketException";

@implementation RHSocketException

+ (void)raiseWithReason:(NSString *)reason
{
    NSString *name = kRHSocketException;
    NSException *exception = [NSException exceptionWithName:name reason:reason userInfo:nil];
    [exception raise];
}

@end
