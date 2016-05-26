//
//  RHSocketPacket.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - socket packet

/**
 *  数据包协议
 */
@protocol RHSocketPacket <NSObject>

@required

/**
 *  数据包携带的数据变量（可以是任何数据格式）
 */
@property (nonatomic, strong) id object;

@optional

/**
 *  类似tag，必要的时候实现，用于区分某个数据包
 */
@property (nonatomic, assign) NSInteger pid;

- (instancetype)initWithObject:(id)aObject;
- (NSData *)dataWithPacket;
- (NSString *)stringWithPacket;

@end

#pragma mark - upstream packet

/**
 *  上行数据包协议，发送数据时，必须遵循的协议
 */
@protocol RHUpstreamPacket <RHSocketPacket>

@optional

/**
 *  发送数据超时时间，必须设置。－1时为无限等待
 */
@property (nonatomic, assign) NSTimeInterval timeout;

@end

#pragma mark - downstream packet

/**
 *  下行数据包协议，接收数据时，必须遵循的协议
 */
@protocol RHDownstreamPacket <RHSocketPacket>

@end
