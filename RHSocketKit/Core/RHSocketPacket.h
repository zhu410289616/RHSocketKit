//
//  RHSocketPacket.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RHSocketPacket <NSObject>

@property (nonatomic, assign, readonly) NSInteger tag;
@property (nonatomic, strong, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data;

@optional

- (void)setTag:(NSInteger)tag;
- (void)setData:(NSData *)data;

@end
