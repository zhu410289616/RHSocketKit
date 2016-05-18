//
//  RHWebSocketConfig.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/18.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHWebSocketConfig : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) NSTimeInterval timeout;

- (NSData *)dataWithHandshake;

@end
