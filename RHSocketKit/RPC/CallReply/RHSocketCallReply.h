//
//  RHSocketCallReply.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCallReplyProtocol.h"
#import "RHSocketConfig.h"

/**
 *  请求
 */
@interface RHSocketCallReply : NSObject <RHSocketCallReplyProtocol>

- (void)setSuccessBlock:(void(^)(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket>response))successBlock;
- (void)setFailureBlock:(void(^)(id<RHSocketCallReplyProtocol> callReply, NSError *error))failureBlock;

@end
