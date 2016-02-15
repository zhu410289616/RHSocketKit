//
//  RHSocketBase64Encoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@interface RHSocketBase64Encoder : NSObject <RHSocketEncoderProtocol>

@property (nonatomic, strong) id<RHSocketEncoderProtocol> nextEncoder;

- (instancetype)initWithStringEncoding:(NSStringEncoding)stringEncoding;

@end
