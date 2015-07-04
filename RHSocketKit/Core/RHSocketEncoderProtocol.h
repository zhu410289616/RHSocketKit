//
//  RHSocketEncoderProtocol.h
//  RHToolkit
//
//  Created by zhuruhong on 15/6/30.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketPacketContent.h"

@protocol RHSocketEncoderOutputDelegate <NSObject>

@required

- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout tag:(NSInteger)tag;

@end

@protocol RHSocketEncoderProtocol <NSObject>

@required

- (void)encodePacket:(id<RHSocketPacketContent>)packet encoderOutput:(id<RHSocketEncoderOutputDelegate>)output;

@end
