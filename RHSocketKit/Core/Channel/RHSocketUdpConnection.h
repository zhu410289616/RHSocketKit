//
//  RHSocketUdpConnection.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/2.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSocketUdpConnection : NSObject

- (void)connectWithHost:(NSString *)hostName port:(int)port;

@end
