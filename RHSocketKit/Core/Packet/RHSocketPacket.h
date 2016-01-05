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
 *  数据包携带的data变量，必须实现data的读取方法
 */
@property (nonatomic, strong, readonly) NSData *data;

@optional

/**
 *  类似tag，必要的时候实现，用于区分某个数据包
 */
@property (nonatomic, assign) NSInteger pid;

- (void)setData:(NSData *)data;

@end

#pragma mark - upstream packet

/**
 *  上行数据包协议，发送数据时，必须遵循的协议
 */
@protocol RHUpstreamPacket <RHSocketPacket>

@required

/**
 *  发送数据超时时间，必须设置。－1时为无限等待
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

@optional

- (void)setTimeout:(NSTimeInterval)timeout;

@end

#pragma mark - downstream packet

/**
 *  下行数据包协议，接收数据时，必须遵循的协议
 */
@protocol RHDownstreamPacket <RHSocketPacket>

@optional

- (instancetype)initWithData:(NSData *)data;

@end
