//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketChannel.h"

#import "RHSocketDelimiterCodec.h"

#import "RHSocketVariableLengthCodec.h"

#import "RHSocketHttpCodec.h"
#import "RHPacketHttpRequest.h"

#import "RHSocketConfig.h"

//
#import "RHSocketService.h"

//
#import "RHSocketChannelProxy.h"
#import "RHConnectCallReply.h"

@interface ViewController () <RHSocketChannelDelegate, RHSocketReplyProtocol>
{
    UIButton *_channelTestButton;
    UIButton *_serviceTestButton;
    UIButton *_proxyTestButton;
    
    RHSocketChannel *_channel;
}

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketServiceState:) name:kNotificationSocketServiceState object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _channelTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _channelTestButton.frame = CGRectMake(20, 40, 130, 40);
    _channelTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _channelTestButton.layer.borderWidth = 0.5;
    _channelTestButton.layer.masksToBounds = YES;
    [_channelTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_channelTestButton setTitle:@"Test Channel" forState:UIControlStateNormal];
    [_channelTestButton addTarget:self action:@selector(doTestChannelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_channelTestButton];
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, CGRectGetMaxY(_channelTestButton.frame) + 20, 130, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test Service" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
    _proxyTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _proxyTestButton.frame = CGRectMake(20, CGRectGetMaxY(_serviceTestButton.frame) + 20, 130, 40);
    _proxyTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _proxyTestButton.layer.borderWidth = 0.5;
    _proxyTestButton.layer.masksToBounds = YES;
    [_proxyTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_proxyTestButton setTitle:@"Test Proxy" forState:UIControlStateNormal];
    [_proxyTestButton addTarget:self action:@selector(doTestProxyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_proxyTestButton];
    
}

#pragma mark - channel test

- (void)doTestChannelButtonAction
{
    
    NSString *host = @"127.0.0.1";
    int port = 7878;
    
    RHSocketDelimiterCodec *codec = [[RHSocketDelimiterCodec alloc] init];
    codec.delimiter = 0x0a;//0x0a，换行符
    
    _channel = [[RHSocketChannel alloc] initWithHost:host port:port];
    _channel.delegate = self;
    _channel.codec = codec;
    [_channel openConnection];
    
}

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"channelOpened: %@:%d", host, port);
    
    RHPacketRequest *req = [[RHPacketRequest alloc] init];
    req.data = [@"RHSocketDelimiterCodec RHPacketRequest" dataUsingEncoding:NSUTF8StringEncoding];
    
    [channel asyncSendPacket:req];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    RHSocketLog(@"channelClosed: %@", error.description);
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    NSString *receive = [[NSString alloc] initWithData:[packet data] encoding:NSUTF8StringEncoding];
    RHSocketLog(@"received: %ld, %@", [packet data].length, receive);
}

#pragma mark - socket service test

- (void)doTestServiceButtonAction
{
    NSString *host = @"www.baidu.com";
    int port = 80;
    
    [RHSocketService sharedInstance].codec = [[RHSocketHttpCodec alloc] init];
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
}

- (void)detectSocketServiceState:(NSNotification *)notif
{
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        RHPacketHttpRequest *req = [[RHPacketHttpRequest alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    } else {
        //
    }//if
}

#pragma mark - channel proxy test

- (void)doTestProxyButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 7878;
    
    RHSocketVariableLengthCodec *codec = [[RHSocketVariableLengthCodec alloc] init];
    
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.delegate = self;
    connect.host = host;
    connect.port = port;
    
    [RHSocketChannelProxy sharedInstance].codec = codec;
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)onSuccess:(id<RHSocketCallReplyProtocol>)aCallReply response:(id<RHDownstreamPacket>)response
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    //测试代码，默认为0，未做修改
    
    NSMutableData *tempData = [NSMutableData dataWithData:[@"123456" dataUsingEncoding:NSUTF8StringEncoding]];
    uint8_t delimiter = 10;
    [tempData appendBytes:&delimiter length:1];
    
    RHPacketRequest *req = [[RHPacketRequest alloc] init];
    req.data = tempData;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

- (void)onFailure:(id<RHSocketCallReplyProtocol>)aCallReply error:(NSError *)error
{}

@end
