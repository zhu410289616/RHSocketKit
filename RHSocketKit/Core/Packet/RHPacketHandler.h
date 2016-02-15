//
//  RHPacketHandler.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@interface RHPacketHandler : NSObject <RHSocketPacket>

@end

/**
 *  根据上行数据包协议实现的最基本的上行请求数据结构对象
 */
@interface RHPacketUpstreamHandler : NSObject <RHUpstreamPacket>

@end

/**
 *  根据下行数据包协议实现的最基本的接收数据包数据结构对象
 */
@interface RHPacketDownstreamHandler : NSObject <RHDownstreamPacket>

@end