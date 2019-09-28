//
//  RHReceivePacketCache.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/28.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHReceivePacketCache.h"

@implementation RHReceivePacketCache

/** 下行数据写入缓存buffer */
- (void)appendReceiveData:(NSData *)receiveData
{
    [super appendReceiveData:receiveData];
}

/** 解码后的数据包，可以再次处理数据包的持久化缓存和状态更新 */
- (void)decodedPakcet:(id<RHDownstreamPacket>)packet
{
    [super decodedPakcet:packet];
    //TODO: 收到数据包，这里可以写入数据库，持久化记录数据
    
}

@end
