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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendAnalyticsToMe = YES;
    }
    return self;
}

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
    channel.writeInterceptor = self.writeInterceptor;
    channel.readInterceptor = self.readInterceptor;
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
    
    /**
     * 这里增加统计请求，只在【DEBUG】环境下生效，可以设置关闭
     */
#ifdef DEBUG
    if (self.sendAnalyticsToMe) {
        [self sendAnalytics];
    }
#endif
}

- (void)sendAnalytics
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://busuanzi.ibruce.info/busuanzi?jsonpCallback=BusuanziCallback_165360587925"]];
    request.HTTPMethod = @"GET";
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36";
    NSString *referer = @"http://zhu410289616.github.io/2019/09/21/RHSocketKit%E4%BD%BF%E7%94%A8%E7%BB%9F%E8%AE%A1/";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:referer forHTTPHeaderField:@"Referer"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request] resume];
}

@end
