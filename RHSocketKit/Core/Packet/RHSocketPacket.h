//
//  RHSocketPacket.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - socket packet

@protocol RHSocketPacket <NSObject>

@required

@property (nonatomic, strong, readonly) NSData *data;

@optional

@property (nonatomic, assign) NSInteger pid;

- (void)setData:(NSData *)data;

@end

#pragma mark - upstream packet

@protocol RHUpstreamPacket <RHSocketPacket>

@required

@property (nonatomic, assign, readonly) NSTimeInterval timeout;

@optional

- (void)setTimeout:(NSTimeInterval)timeout;

@end

#pragma mark - downstream packet

@protocol RHDownstreamPacket <RHSocketPacket>

@optional

- (instancetype)initWithData:(NSData *)data;

@end
