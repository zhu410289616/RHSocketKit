//
//  RHUpstreamBuffer.m
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHUpstreamBuffer.h"

@implementation RHUpstreamBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _packetBuffer = [[NSMutableArray alloc] init];
        _maxPacketSize = 30;
    }
    return self;
}

- (void)appendSendPacket:(id<RHUpstreamPacket>)packet
                  encode:(RHUpstreamBufferEncode)encodeCallback
                overflow:(RHUpstreamBufferOverflow)overflowCallback
{
    if (nil == packet) {
        return;
    }
    
    if (nil == encodeCallback) {
#ifdef DEBUG
        NSAssert(YES, @"[Error]: upstream buffer encodeCallback is nil :(");
#endif
        return;
    }
    
    @synchronized (self) {
        [self.packetBuffer addObject:packet];
        
        if (encodeCallback) {
            encodeCallback(self.packetBuffer);
        }
        
        if (overflowCallback && self.packetBuffer.count > self.maxPacketSize) {
            overflowCallback(self);
        }
    }
}

- (NSArray *)packetsForFlush
{
    @synchronized (self) {
        NSArray *theFlushPackets = [self.packetBuffer mutableCopy];
        [self.packetBuffer removeAllObjects];
        return theFlushPackets;
    }
}

@end
