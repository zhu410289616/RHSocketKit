//
//  RHConnectCallReply.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/22.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketCallReply.h"

/**
 *  连接服务器结构对象
 */
@interface RHConnectCallReply : RHSocketCallReply

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) int port;

@end
