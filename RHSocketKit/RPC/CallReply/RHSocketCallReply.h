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

typedef void(^RHSocketReplySuccessBlock)(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket>response);
typedef void(^RHSocketReplyFailureBlock)(id<RHSocketCallReplyProtocol> callReply, NSError *error);

/**
 *  请求
 */
@interface RHSocketCallReply : NSObject <RHSocketCallReplyProtocol>

@property (nonatomic, copy) RHSocketReplySuccessBlock successBlock;
@property (nonatomic, copy) RHSocketReplyFailureBlock failureBlock;

@end
