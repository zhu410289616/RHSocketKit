//
//  RHSocketJSONSerializationDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@interface RHSocketJSONSerializationDecoder : NSObject <RHSocketDecoderProtocol>

@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;

@end
