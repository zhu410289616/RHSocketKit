//
//  RHUpstreamBuffer.m
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHUpstreamBuffer.h"

@interface RHUpstreamBuffer ()

@property (nonatomic, strong) NSMutableArray *packetBuffer;

@end

@implementation RHUpstreamBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _packetBuffer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)appendSendPacket:(id<RHUpstreamPacket>)packet
{
    if (nil == packet) {
        return;
    }
    
    NSAssert(_delegate, @"[Error]: RHUpstreamBuffer delegate is nil");
    
    @synchronized (self) {
        [_packetBuffer addObject:packet];
        
        [_delegate packetWillEncode:_packetBuffer];
        
        if (_packetBuffer.count > _maxPacketSize) {
            [_delegate upstreamBufferOverflow:self];
        }
    }
}

- (NSArray *)packetsForFlush
{
    @synchronized (self) {
        NSArray *theFlushPackets = [_packetBuffer mutableCopy];
        [_packetBuffer removeAllObjects];
        return theFlushPackets;
    }
}

@end
