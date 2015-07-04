//
//  RHSocketDecoderProtocol.h
//  RHToolkit
//
//  Created by zhuruhong on 15/6/30.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacket.h"

@protocol RHSocketDecoderOutputDelegate <NSObject>

@required

- (void)didDecode:(id<RHSocketPacket>)packet tag:(NSInteger)tag;

@end

@protocol RHSocketDecoderProtocol <NSObject>

@required

- (NSUInteger)decodeData:(NSData *)data decoderOutput:(id<RHSocketDecoderOutputDelegate>)output tag:(long)tag;

@end
