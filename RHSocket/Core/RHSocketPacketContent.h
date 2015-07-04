//
//  RHSocketPacketContent.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/19.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@protocol RHSocketPacketContent <RHSocketPacket>

@property (nonatomic, readonly) NSTimeInterval timeout;

@optional

- (void)setTimeout:(NSTimeInterval)timeout;

@end
