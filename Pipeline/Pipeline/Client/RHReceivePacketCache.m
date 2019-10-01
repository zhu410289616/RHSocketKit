//
//  RHReceivePacketCache.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/28.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHReceivePacketCache.h"

@implementation RHReceivePacketCache

/** 解码后的数据包，可以再次处理数据包的持久化缓存和状态更新 */
- (void)decodedPakcet:(id<RHDownstreamPacket>)packet
{
    //TODO: 收到数据包，这里可以写入数据库，持久化记录数据
    //比如：之前发送某条消息时，被标记为发送中，现在收到这条消息的服务端已经接收的ack，则可以更新本地数据为已发送
    RHSocketLog(@"[Logic]: 收到数据包，这里可以写入数据库，持久化记录数据。比如：之前发送某条消息时，被标记为发送中，现在收到这条消息的服务端已经接收的ack，则可以更新本地数据为已发送");
}

@end
