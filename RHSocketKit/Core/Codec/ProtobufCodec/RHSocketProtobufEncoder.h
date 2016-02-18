//
//  RHSocketProtobufEncoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@interface RHSocketProtobufEncoder : NSObject <RHSocketEncoderProtocol>

@property (nonatomic, strong) id<RHSocketEncoderProtocol> nextEncoder;

@end
