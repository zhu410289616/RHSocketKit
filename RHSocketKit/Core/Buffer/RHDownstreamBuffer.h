//
//  RHDownstreamBuffer.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHChannelBufferProtocol.h"

//NS_ASSUME_NONNULL_BEGIN

/**
 *  下行数据包缓存
 */
@interface RHDownstreamBuffer : NSObject <RHDownstreamBuffer>

/** 缓存数据块最大值，默认为8192 */
@property (nonatomic, assign) NSUInteger maxBufferSize;
/** 缓存收到下行数据回调 */
@property (nonatomic,   weak) id<RHDownstreamBufferDelegate> delegate;

@end

//NS_ASSUME_NONNULL_END
