//
//  RHSocketCustomResponse.h
//  RHSocketCustomCodecDemo
//
//  Created by zhuruhong on 16/3/30.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketPacketContext.h"

@interface RHSocketCustomResponse : RHSocketPacketResponse

@property (nonatomic, assign) int16_t fenGeFu;
@property (nonatomic, assign) int16_t dataType;

@end
