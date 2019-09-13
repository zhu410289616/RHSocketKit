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

/** 数据发送时使用的编码器 */
@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
/** 数据接收后处理的解码器 */
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;
@property (nonatomic, strong) RHChannelBeats *channelBeats;
@property (nonatomic, strong) RHSocketConnectParam *connectParam;
@property (nonatomic, strong) RHChannelService *channelService;

@end

@implementation RHClientViewController

- (RHChannelBeats *)channelBeats
{
    if (nil == _channelBeats) {
        _channelBeats = [[RHChannelBeats alloc] init];
    }
    return _channelBeats;
}

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
    _connectParam.heartbeatInterval = 5;
    
    switch (_codecType) {
        case RHTestCodecTypeDelimiter:
        {
            _encoder = [[RHSocketDelimiterEncoder alloc] init];
            _decoder = [[RHSocketDelimiterDecoder alloc] init];
        }
            break;
        case RHTestCodecTypeVariableLength:
        {
            _encoder = [[RHSocketVariableLengthEncoder alloc] init];
            _decoder = [[RHSocketVariableLengthDecoder alloc] init];
        }
            break;
        case RHTestCodecTypeProtobuf:
        {
            _encoder = [[RHProtobufVarint32LengthEncoder alloc] init];
            _decoder = [[RHProtobufVarint32LengthDecoder alloc] init];
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    
    //心跳
    [self.channelBeats stop];
    self.channelBeats.interval = _connectParam.heartbeatInterval;
    self.channelBeats.beatBlock = ^(RHChannelBeats *channelBeats) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.connectParam.heartbeatEnabled) {
            return;
        }
        //发送心跳包
        RHSocketLog(@"[Log]: channel beats");
        
        //测试心跳包
        NSDate *currentTime = [NSDate date];
        NSString *text = [NSString stringWithFormat:@"111111 我是是是是心跳包啊 %@", currentTime];
        RHSocketPacketRequest *heartbeat = [[RHSocketPacketRequest alloc] init];
        heartbeat.object = text;
        [strongSelf.channelService asyncSendPacket:heartbeat];
    };
    self.channelBeats.overBlock = ^(RHChannelBeats *channelBeats) {
        RHSocketLog(@"[Log]: channel beats over");
    };
    
    [self.channelService startWithConfig:^(RHChannelConfig *config) {
        config.connectParam = weakSelf.connectParam;
        config.encoder = weakSelf.encoder;
        config.decoder = weakSelf.decoder;
        config.channelBeats = weakSelf.channelBeats;
        config.delegate = self;
    }];
    
    //测试发送缓存
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = @"222222 测试发送缓存";
    [self.channelService asyncSendPacket:req];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.channelService.channel addDelegate:self];
//    [self.channelService startServiceWithConnectParam:self.connectParam];
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
