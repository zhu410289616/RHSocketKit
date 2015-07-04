//
//  RHPacketHead.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/19.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@interface RHPacketHead : NSObject <RHSocketPacket>

- (NSUInteger)packetLength;
- (NSInteger)packetCommand;

@end
