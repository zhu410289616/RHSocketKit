//
//  RHChannelConfig.m
//  Pods
//
//  Created by zhuruhong on 2019/9/13.
//

#import "RHChannelConfig.h"
#import "RHUpstreamBuffer.h"
#import "RHDownstreamBuffer.h"
#import "RHSocketMacros.h"

@implementation RHChannelConfig

#ifdef DEBUG
- (void)dealloc
{
    RHSocketLog(@"[Log]: %@ dealloc", self.class);
}
#endif

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

- (RHChannelBeats *)channelBeats
{
    if (nil == _channelBeats) {
        _channelBeats = [[RHChannelBeats alloc] init];
    }
    return _channelBeats;
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
    
    if (self.connectParam.heartbeatEnabled) {
        self.channelBeats.interval = self.connectParam.heartbeatInterval;
        self.channelBeats.beatBlock = ^(RHChannelBeats *channelBeats) {
            //心跳包
            RHSocketLog(@"[Log]: channel beats");
            id<RHUpstreamPacket> heartbeat = RHSocketBlockRun(channelBeats.heartbeatBlock);
            [channel asyncSendPacket:heartbeat];
        };
        self.channelBeats.overBlock = ^(RHChannelBeats *channelBeats) {
            RHSocketLog(@"[Log]: channel beats over");
        };
    }
}

@end
