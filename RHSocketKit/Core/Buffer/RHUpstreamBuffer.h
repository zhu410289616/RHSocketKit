//
//  RHUpstreamBuffer.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  上行数据包缓存
 */
@interface RHUpstreamBuffer : NSObject

/**
 *  缓存数据包个数，默认为30
 */
@property (nonatomic, assign) NSUInteger maxPacketSize;

@end

NS_ASSUME_NONNULL_END
