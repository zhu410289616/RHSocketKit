//
//  RHPacketHttpRequest.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/2.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketBody.h"

@interface RHPacketHttpRequest : RHPacketBody

@property (nonatomic, copy) NSString *requestPath;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *connection;

@end
