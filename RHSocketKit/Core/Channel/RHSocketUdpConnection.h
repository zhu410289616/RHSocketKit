//
//  RHSocketUdpConnection.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/2.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSocketUdpConnection : NSObject

- (void)setupUdpSocket;

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port;
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(int)port tag:(long)tag;

@end
