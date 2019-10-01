//
//  RHSendPacketCache.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/28.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHSendPacketCache.h"

@implementation RHSendPacketCache

/** 上行数据写入缓存buffer */
- (void)appendSendPacket:(id<RHUpstreamPacket>)packet encode:(RHUpstreamBufferEncode)encodeCallback overflow:(RHUpstreamBufferOverflow)overflowCallback
{
    [super appendSendPacket:packet encode:encodeCallback overflow:overflowCallback];
    //TODO: 数据包为发送中状态，写入数据库
    //比如：数据发送后，标记数据为发送中状态，等待服务端确认已接收
    RHSocketLog(@"[Logic]: 数据包为发送中状态，写入数据库。比如：数据发送后，标记数据为发送中状态，等待服务端确认已接收");
}

/** 返回缓存的数据包，同时清空缓存 */
- (NSArray *)packetsForFlush
{
    //TODO: 可以读取数据库，为发送成功的数据包，重新发送
    //比如：网络断开后，发送中的数据可能已经发送失败；检测到网络重连后，重新发送一次发送中的数据
    RHSocketLog(@"[Logic]: 可以读取数据库，为发送成功的数据包，重新发送。比如：网络断开后，发送中的数据可能已经发送失败；检测到网络重连后，重新发送一次发送中的数据");
    return [super packetsForFlush];
}

@end
