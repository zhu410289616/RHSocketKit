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

@interface RHSocketCallReply : NSObject <RHSocketCallReplyProtocol>

@property (nonatomic, weak) id<RHSocketReplyProtocol> delegate;

@end
