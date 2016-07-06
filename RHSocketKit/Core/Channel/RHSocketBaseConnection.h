//
//  RHSocketBaseConnection.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GCDAsyncSocket.h"
#import "RHSocketConnectionDelegate.h"
#import "RHSocketConfig.h"

@class GCDAsyncSocket;

@interface RHSocketBaseConnection : NSObject <RHSocketConnectionDelegate>

@property (nonatomic, strong, readonly) GCDAsyncSocket *asyncSocket;

@property (nonatomic, assign) BOOL useSecureConnection;
@property (nonatomic, strong) NSDictionary *tlsSettings;

@end
