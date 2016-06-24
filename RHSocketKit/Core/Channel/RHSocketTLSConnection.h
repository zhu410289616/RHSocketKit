//
//  RHSocketTLSConnection.h
//  Example
//
//  Created by zhuruhong on 16/6/24.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketBaseConnection.h"

@interface RHSocketTLSConnection : RHSocketBaseConnection

@property (nonatomic, assign) BOOL useSecureConnection;
@property (nonatomic, strong) NSDictionary *tlsSettings;

@end
