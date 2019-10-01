//
//  NSObject+RHExtends.h
//  Pods
//
//  Created by zhuruhong on 2019/10/1.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RHExtends)

@end

@interface NSObject (RHQueue)

- (void)rh_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block async:(BOOL)async;

@end

//NS_ASSUME_NONNULL_END
