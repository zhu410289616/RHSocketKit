//
//  RHChannelConfig.m
//  Pods
//
//  Created by zhuruhong on 2019/9/13.
//

#import "RHChannelConfig.h"
#import "RHUpstreamBuffer.h"
#import "RHDownstreamBuffer.h"

@implementation RHChannelConfig

- (id<RHUpstreamBuffer>)upstreamBuffer
{
    if (nil == _upstreamBuffer) {
        _upstreamBuffer = [[RHUpstreamBuffer alloc] init];
    }
    return _upstreamBuffer;
}

- (id<RHDownstreamBuffer>)downstreamBuffer
{
    if (nil == _downstreamBuffer) {
        _downstreamBuffer = [[RHDownstreamBuffer alloc] init];
    }
    return _downstreamBuffer;
}

- (void)setup:(RHSocketChannel *)channel
{
    channel.connectParam = self.connectParam;
    channel.upstreamBuffer = self.upstreamBuffer;
    channel.upstreamBuffer.delegate = channel;
    channel.downstreamBuffer = self.downstreamBuffer;
    channel.downstreamBuffer.delegate = channel;
    channel.encoder = self.encoder;
    channel.decoder = self.decoder;
    [channel addDelegate:self.delegate];
}

@end
