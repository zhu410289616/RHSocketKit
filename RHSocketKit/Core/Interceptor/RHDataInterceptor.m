//
//  RHDataInterceptor.m
//  Pods
//
//  Created by zhuruhong on 2019/9/26.
//

#import "RHDataInterceptor.h"
#import "RHSocketMacros.h"

@implementation RHDataInterceptor

- (NSData *)interceptor:(NSData *)interceptData userInfo:(NSDictionary *)userInfo
{
    NSData *theData = interceptData;
    RHSocketLog(@"[Hook]: intercept data: %@, %@", theData, userInfo);
    if ([self.nextInterceptor respondsToSelector:@selector(interceptor:userInfo:)]) {
        theData = [self.nextInterceptor interceptor:theData userInfo:userInfo];
    }
    return theData;
}

@end
