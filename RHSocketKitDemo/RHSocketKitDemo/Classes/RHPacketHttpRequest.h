//
//  RHPacketHttpRequest.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/2.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHPacketRequest.h"

@interface RHPacketHttpRequest : RHPacketRequest

@property (nonatomic, copy) NSString *requestPath;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *connection;

@end
