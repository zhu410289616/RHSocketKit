//
//  RHPacketResponse.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/18.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

/**
 *  根据下行数据包协议实现的最基本的接收数据包数据结构对象
 */
@interface RHPacketResponse : NSObject <RHDownstreamPacket>

@end
