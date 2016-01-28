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

/**
 *  记录正在处理的请求对象，用于管理请求的超时时间等等
 *
 *  @param aCallReply 实现RHSocketCallReplyProtocol协议对象
 */
- (void)addCallReply:(id<RHSocketCallReplyProtocol>)aCallReply;

/**
 *  根据id获取记录的请求对象
 *
 *  @param aCallReplyId RHSocketCallReplyProtocol协议对象唯一id
 *
 *  @return 实现RHSocketCallReplyProtocol协议对象
 */
- (id<RHSocketCallReplyProtocol>)getCallReplyWithId:(NSInteger)aCallReplyId;

/**
 *  根据id移除记录的请求对象，多用于请求已返回和请求超时。
 *
 *  @param aCallReplyId RHSocketCallReplyProtocol协议对象唯一id
 */
- (void)removeCallReplyWithId:(NSInteger)aCallReplyId;

/**
 *  异常时移除所有记录的请求对象
 */
- (void)removeAllCallReply;

@end
