//
//  RHProtobufVarint32LengthDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/26.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"

@interface RHProtobufVarint32LengthDecoder : NSObject <RHSocketDecoderProtocol>

/**
 *  应用协议中允许发送的最大数据块大小，默认为65536
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;

@end
