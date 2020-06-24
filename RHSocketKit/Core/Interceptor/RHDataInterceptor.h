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

@end

@interface RHDataToFileInterceptor : NSObject <RHSocketInterceptorProtocol>

@property (nonatomic, strong) NSString *filePath;

- (instancetype)initWithFileName:(NSString *)fileName;
- (instancetype)initWithFilePath:(NSString *)filePath;


@end

//NS_ASSUME_NONNULL_END
