//
//  RHSocketHttpService.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/7/2.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketHttpService.h"
#import "RHSocketHttpEncoder.h"
#import "RHSocketHttpDecoder.h"
#import "RHSocketConfig.h"

@implementation RHSocketHttpService

- (instancetype)init
{
    if (self = [super init]) {
        self.encoder = [[RHSocketHttpEncoder alloc] init];
        self.decoder = [[RHSocketHttpDecoder alloc] init];
    }
    return self;
}

- (void)didDecode:(id<RHSocketPacket>)packet tag:(NSInteger)tag
{
    [super didDecode:packet tag:tag];
    
    RHSocketLog(@"packet: %@", [[NSString alloc] initWithData:[packet data] encoding:NSASCIIStringEncoding]);
}

@end
