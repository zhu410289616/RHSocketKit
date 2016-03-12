//
//  RHSocketPacketContext.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@interface RHSocketPacketContext : NSObject <RHUpstreamPacket, RHDownstreamPacket>

@end

@interface RHSocketPacketRequest : RHSocketPacketContext

@end

@interface RHSocketPacketResponse : RHSocketPacketContext

@end