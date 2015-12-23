//
//  RHSocketCallReplyManager.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCallReplyProtocol.h"

@interface RHSocketCallReplyManager : NSObject

- (void)addCallReply:(id<RHSocketCallReplyProtocol>)aCallReply;
- (id<RHSocketCallReplyProtocol>)getCallReplyWithId:(NSInteger)aCallReplyId;
- (void)removeCallReplyWithId:(NSInteger)aCallReplyId;
- (void)removeAllCallReply;

@end
