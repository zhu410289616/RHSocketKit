//
//  NSObject+RHExtends.m
//  Pods
//
//  Created by zhuruhong on 2019/10/1.
//

#import "NSObject+RHExtends.h"

@implementation NSObject (RHExtends)

@end

@implementation NSObject (RHQueue)

- (void)rh_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block async:(BOOL)async
{
    if (async) {
        dispatch_async(queue, ^{
            @autoreleasepool {
                block();
            }
        });
        return;
    }
    
    dispatch_sync(queue, ^{
        @autoreleasepool {
            block();
        }
    });
}

@end
