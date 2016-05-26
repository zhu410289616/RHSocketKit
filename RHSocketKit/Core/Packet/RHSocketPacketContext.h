//
//  RHSocketPacketContext.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

#pragma mark - RHSocketPacketContext

@interface RHSocketPacketContext : NSObject <RHUpstreamPacket, RHDownstreamPacket>

@end

#pragma mark - RHSocketPacketRequest

@interface RHSocketPacketRequest : RHSocketPacketContext

@end

#pragma mark - RHSocketPacketResponse

@interface RHSocketPacketResponse : RHSocketPacketContext

@end