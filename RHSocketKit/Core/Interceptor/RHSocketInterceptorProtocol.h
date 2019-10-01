//
//  RHSocketInterceptorProtocol.h
//  Pods
//
//  Created by zhuruhong on 2019/9/26.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@protocol RHSocketInterceptorProtocol <NSObject>

@required

@property (nonatomic, strong) id<RHSocketInterceptorProtocol> nextInterceptor;

@required

- (NSData *)interceptor:(NSData *)interceptData userInfo:(NSDictionary *)userInfo;

@end

//NS_ASSUME_NONNULL_END
