//
//  RHSocketHttpRequest.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/16.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketPacketContext.h"

@interface RHSocketHttpRequest : RHSocketPacketRequest

@property (nonatomic, copy) NSString *requestPath;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *connection;

- (NSData *)data;

@end
