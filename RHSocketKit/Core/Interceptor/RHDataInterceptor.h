//
//  RHDataInterceptor.h
//  Pods
//
//  Created by zhuruhong on 2019/9/26.
//

#import <Foundation/Foundation.h>
#import "RHSocketInterceptorProtocol.h"

//NS_ASSUME_NONNULL_BEGIN

@interface RHDataInterceptor : NSObject <RHSocketInterceptorProtocol>

@property (nonatomic, strong) id<RHSocketInterceptorProtocol> nextInterceptor;

@end

//NS_ASSUME_NONNULL_END
