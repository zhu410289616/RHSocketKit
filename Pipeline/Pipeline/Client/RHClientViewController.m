//
//  RHClientViewController.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/10.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHClientViewController.h"
#import <RHSocketKit/RHSocketKit.h>

#import <RHSocketKit/RHSocketStringDecoder.h>
#import <RHSocketKit/RHSocketStringEncoder.h>

//http
#import "RHSocketHttpEncoder.h"
#import "RHSocketHttpDecoder.h"
#import "RHSocketHttpRequest.h"
#import "RHSocketHttpResponse.h"

//custom
#import "RHSocketCustom0330Encoder.h"
#import "RHSocketCustom0330Decoder.h"
#import "RHSocketCustomRequest.h"
#import "RHSocketCustomResponse.h"

@interface RHClientViewController () <RHSocketChannelDelegate>

/** 数据发送时使用的编码器 */
@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
/** 数据接收后处理的解码器 */
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _connectParam = [[RHSocketConnectParam alloc] init];
    _connectParam.host = @"127.0.0.1";
    _connectParam.port = 4522;
    _connectParam.heartbeatInterval = 5;
    
    switch (_codecType) {
        case RHTestCodecTypeDelimiter:
        {
            RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
            encoder.delimiterData = [RHSocketUtils dataFromHexString:@"0d0a"];//0d0a，换行符
            RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
            decoder.delimiterData = [RHSocketUtils dataFromHexString:@"0d0a"];//0d0a，换行符
            _encoder = encoder;
            _decoder = decoder;
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
        case RHTestCodecTypeHttp:
        {
            _connectParam.host = @"www.baidu.com";
            _connectParam.port = 80;
            _connectParam.heartbeatEnabled = NO;
            
            RHSocketHttpEncoder *encoder = [[RHSocketHttpEncoder alloc] init];
            RHSocketHttpDecoder *decoder = [[RHSocketHttpDecoder alloc] init];
            RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
            decoder.nextDecoder = stringDecoder;
            _encoder = encoder;
            _decoder = decoder;
        }
            break;
        case RHTestCodecTypeCustom:
        {
            _connectParam.heartbeatEnabled = NO;
            
            //变长编解码。包体＝包头（包体的长度）＋包体数据
            RHSocketCustom0330Encoder *encoder = [[RHSocketCustom0330Encoder alloc] init];
            RHSocketCustom0330Decoder *decoder = [[RHSocketCustom0330Decoder alloc] init];
            _encoder = encoder;
            _decoder = decoder;
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    
    //测试心跳包
    RHSocketPacketRequest *heartbeat = [self heartbeatWithCodecType:self.codecType];
    //开启连接通道
    [self.channelService startWithConfig:^(RHChannelConfig *config) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        config.connectParam = strongSelf.connectParam;
        config.encoder = strongSelf.encoder;
        config.decoder = strongSelf.decoder;
        config.channelBeats.heartbeatBlock = ^id<RHUpstreamPacket>{
            return heartbeat;
        };
        config.delegate = strongSelf;
    }];
    
    //测试发送缓存
    RHSocketPacketRequest *req = [self requestWithCodecType:self.codecType];
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

#pragma mark - heartbeat packet

- (RHSocketPacketRequest *)heartbeatWithCodecType:(RHTestCodecType)codecType
{
    NSDate *currentTime = [NSDate date];
    NSString *text = [NSString stringWithFormat:@"111111 我是是是是心跳包啊 %@", currentTime];
    RHSocketPacketRequest *heartbeat = [[RHSocketPacketRequest alloc] init];
    heartbeat.object = text;
    return heartbeat;
}

#pragma mark - send test packet

- (RHSocketPacketRequest *)requestWithCodecType:(RHTestCodecType)codecType
{
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = @"222222 测试发送缓存";
    
    switch (codecType) {
        case RHTestCodecTypeDelimiter:
        {
            //上面都是一条一条发送的，编码器会自动加上分隔符。服务端返回也是一条一条的。不太容易出现3条一起返回的。
            //这里我们模拟一个几条数据组装在一起返回的。
            NSMutableData *someData = [[NSMutableData alloc] init];
            [someData appendData:[@"第1块数据" dataUsingEncoding:NSUTF8StringEncoding]];
            [someData appendData:[RHSocketUtils dataFromHexString:@"0d0a"]];//手动加入分隔符，模拟几条数据一起的数据块
            [someData appendData:[@"第2块数据" dataUsingEncoding:NSUTF8StringEncoding]];
            [someData appendData:[RHSocketUtils dataFromHexString:@"0d0a"]];//手动加入分隔符，模拟几条数据一起的数据块
            [someData appendData:[@"第3块数据" dataUsingEncoding:NSUTF8StringEncoding]];
            req.object = someData;
        }
            break;
            
        default:
            break;
    }
    
    return req;
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"[Log]: channel opened %@:%d", host, port);
    
    if (self.codecType == RHTestCodecTypeHttp) {
        RHSocketHttpRequest *req = [[RHSocketHttpRequest alloc] init];
        [self.channelService asyncSendPacket:req];
        return;
    } else if (self.codecType == RHTestCodecTypeCustom) {
        //连接成功后，发送数据包
        RHSocketCustomRequest *req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 1234;
        req.object = [@"自定义编码器和解码器测试数据包1" dataUsingEncoding:NSUTF8StringEncoding];
        [self.channelService asyncSendPacket:req];
        
        req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 12;
        req.object = [@"自定义编码器和解码器测试数据包20" dataUsingEncoding:NSUTF8StringEncoding];
        [self.channelService asyncSendPacket:req];
        
        req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 0;
        req.object = [@"自定义编码器和解码器测试数据包300" dataUsingEncoding:NSUTF8StringEncoding];
        [self.channelService asyncSendPacket:req];
    }
    
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
    
    if ([packet isKindOfClass:[RHSocketHttpResponse class]]) {
        RHSocketLog(@"[Log]: Http Response = %@", [packet object]);
    }
}

@end
