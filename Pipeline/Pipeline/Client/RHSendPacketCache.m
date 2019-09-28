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
- (void)appendSendPacket:(id<RHUpstreamPacket>)packet
{
    [super appendSendPacket:packet];
    //TODO: 数据包为发送中状态，写入数据库
}
/** 返回缓存的数据包，同时清空缓存 */
- (NSArray *)packetsForFlush
{
    //TODO: 可以读取数据库，为发送成功的数据包，重新发送
    
    return [super packetsForFlush];
}

@end
