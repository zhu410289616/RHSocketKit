//
//  RHDataInterceptor.m
//  Pods
//
//  Created by zhuruhong on 2019/9/26.
//

#import "RHDataInterceptor.h"
#import "RHSocketMacros.h"

@implementation RHDataInterceptor

- (NSData *)interceptor:(NSData *)interceptData error:(NSError *)error
{
    NSData *theData = interceptData;
    RHSocketLog(@"[Log]: intercept data: %@", theData);
    if ([self.nextInterceptor respondsToSelector:@selector(interceptor:error:)]) {
        theData = [self.nextInterceptor interceptor:theData error:error];
    }
    return theData;
}

@end
