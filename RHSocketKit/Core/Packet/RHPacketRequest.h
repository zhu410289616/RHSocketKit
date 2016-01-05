//
//  RHPacketRequest.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/18.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

/**
 *  根据上行数据包协议实现的最基本的上行请求数据结构对象
 */
@interface RHPacketRequest : NSObject <RHUpstreamPacket>

@end
