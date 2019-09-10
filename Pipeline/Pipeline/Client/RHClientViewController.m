//
//  RHClientViewController.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/10.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHClientViewController.h"
#import <RHSocketKit/RHSocketKit.h>

@interface RHClientViewController () <RHSocketChannelDelegate>

@property (nonatomic, strong) RHSocketConnectParam *connectParam;
@property (nonatomic, strong) RHChannelService *channelService;

@end

@implementation RHClientViewController

- (RHChannelService *)channelService
{
    if (nil == _channelService) {
        _channelService = [[RHChannelService alloc] init];
    }
    return _channelService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _connectParam = [[RHSocketConnectParam alloc] init];
    _connectParam.host = @"127.0.0.1";
    _connectParam.port = 4522;
    
    switch (_codecType) {
        case RHTestCodecTypeDelimiter:
        {
            self.channelService.encoder = [[RHSocketDelimiterEncoder alloc] init];
            self.channelService.decoder = [[RHSocketDelimiterDecoder alloc] init];
        }
            break;
            
        default:
            break;
    }
    
    //测试心跳包
    RHSocketPacketRequest *heartbeat = [[RHSocketPacketRequest alloc] init];
    heartbeat.object = @"111111 我是是是是心跳包啊";
    self.channelService.heartbeat = heartbeat;
    
    //测试发送缓存
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = @"222222 测试发送缓存";
    [self.channelService asyncSendPacket:req];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.channelService.channel addDelegate:self];
    [self.channelService startServiceWithConnectParam:self.connectParam];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.channelService.channel removeDelegate:self];
    [self.channelService stopService];
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"[Log]: channel opened %@:%d", host, port);
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = @"333333 测试发送数据包";
    [self.channelService asyncSendPacket:req];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    RHSocketLog(@"[Log]: channel closed %@", error);
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"[Log]: received %@", [packet dataWithPacket]);
}

@end
