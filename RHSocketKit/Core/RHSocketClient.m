//
//  RHSocketClient.m
//  Pods
//
//  Created by zhuruhong on 2019/9/13.
//

#import "RHSocketClient.h"

@implementation RHSocketClient

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
