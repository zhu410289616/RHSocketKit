//
//  RHSocketException.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/1.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketConfig.h"

extern NSString *const kRHSocketException;

@interface RHSocketException : NSObject

+ (void)raiseWithReason:(NSString *)reason;

@end
