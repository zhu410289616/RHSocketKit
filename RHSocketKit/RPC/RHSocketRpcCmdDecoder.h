//
//  RHSocketRpcCmdDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/3/12.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@interface RHSocketRpcCmdDecoder : NSObject <RHSocketDecoderProtocol>

@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;

@end
