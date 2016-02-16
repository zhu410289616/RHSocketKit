//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketChannel.h"

#import "RHSocketStringEncoder.h"
#import "RHSocketStringDecoder.h"

#import "RHSocketBase64Encoder.h"
#import "RHSocketBase64Decoder.h"

#import "RHSocketJSONSerializationEncoder.h"
#import "RHSocketJSONSerializationDecoder.h"

#import "RHSocketZlibCompressionEncoder.h"
#import "RHSocketZlibCompressionDecoder.h"

#import "RHSocketProtobufEncoder.h"
#import "RHSocketProtobufDecoder.h"

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketDelimiterDecoder.h"

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"

#import "RHSocketHttpEncoder.h"
#import "RHSocketHttpDecoder.h"
#import "RHSocketHttpRequest.h"
#import "RHSocketHttpResponse.h"

#import "RHSocketConfig.h"

//
#import "RHSocketService.h"

//
#import "RHSocketChannelProxy.h"
#import "RHConnectCallReply.h"
#import "EXTScope.h"

//
#import "RHSocketUtils.h"

@interface ViewController () <RHSocketChannelDelegate>
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketPacketResponse:) name:kNotificationSocketPacketResponse object:nil];
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
    
    
    //
    NSData *data = [RHSocketUtils dataFromHexString:@"24211D3498FF62AF"];
    RHSocketLog(@"data: %@", data);
    
    data = [RHSocketUtils dataWithReverse:data];
    RHSocketLog(@"Reverse data: %@", data);
    
    NSString *hexString = [RHSocketUtils hexStringFromData:data];
    RHSocketLog(@"hexString: %@", hexString);
    
    NSString *asciiString = [RHSocketUtils asciiStringFromHexString:@"00de0f1a8b24211D3498FF62AF"];
    RHSocketLog(@"asciiString: %@", asciiString);
    
    hexString = [RHSocketUtils hexStringFromASCIIString:asciiString];
    RHSocketLog(@"hexString: %@", hexString);
    
    hexString = [RHSocketUtils hexStringFromASCIIString:@"343938464636324146"];
    RHSocketLog(@"hexString: %@", hexString);
    
    hexString = [RHSocketUtils hexStringFromASCIIString:@"3030646530663161386232343231314433"];
    RHSocketLog(@"hexString: %@", hexString);
    
    NSUInteger value = 4294967295;
    data = [RHSocketUtils bytesFromValue:value byteCount:4];
    RHSocketLog(@"data: %@", data);
    value = [RHSocketUtils valueFromBytes:data];
    RHSocketLog(@"value: %lu", (unsigned long)value);
    
    value = 300;//对应十六进制 0x12c
    data = [RHSocketUtils bytesFromValue:value byteCount:4];
    RHSocketLog(@"data: %@", data);//转换为低位在前高位在后的data 2c 01 00 00
    value = [RHSocketUtils valueFromBytes:data];
    RHSocketLog(@"value: %lu", (unsigned long)value);//将低位在前高位在后的data还原 300
    
    value = 255;
    data = [RHSocketUtils bytesFromValue:value byteCount:3];
    RHSocketLog(@"reverse[YES] data: %@", data);
    value = [RHSocketUtils valueFromBytes:data];
    RHSocketLog(@"reverse[YES] value: %lu", (unsigned long)value);
    
    value = 255;
    data = [RHSocketUtils bytesFromValue:value byteCount:3 reverse:NO];
    RHSocketLog(@"reverse[NO] data: %@", data);
    value = [RHSocketUtils valueFromBytes:data reverse:NO];
    RHSocketLog(@"reverse[NO] value: %lu", (unsigned long)value);
    
    value = 74;
    data = [RHSocketUtils bytesFromValue:value byteCount:2];
    RHSocketLog(@"reverse[YES] data: %@", data);
    value = [RHSocketUtils valueFromBytes:data];
    RHSocketLog(@"reverse[YES] value: %lu", (unsigned long)value);
    
    value = 74;
    data = [RHSocketUtils bytesFromValue:value byteCount:2 reverse:NO];
    RHSocketLog(@"reverse[NO] data: %@", data);
    value = [RHSocketUtils valueFromBytes:data reverse:NO];
    RHSocketLog(@"reverse[NO] value: %lu", (unsigned long)value);
    
    value = 74;
    data = [RHSocketUtils bytesFromValue:value byteCount:1];
    RHSocketLog(@"data: %@", data);
    value = [RHSocketUtils valueFromBytes:data];
    RHSocketLog(@"value: %lu", (unsigned long)value);
    
}

#pragma mark - channel test

- (void)doTestChannelButtonAction
{
    
    NSString *host = @"127.0.0.1";
    int port = 7878;
    
    //
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiter = 0x0a;//0x0a，换行符
    
    RHSocketStringEncoder *stringEncoder = [[RHSocketStringEncoder alloc] init];
    stringEncoder.nextEncoder = encoder;
    
    RHSocketBase64Encoder *base64Encoder = [[RHSocketBase64Encoder alloc] init];
    base64Encoder.nextEncoder = encoder;
    
    RHSocketJSONSerializationEncoder *jsonEncoder = [[RHSocketJSONSerializationEncoder alloc] init];
    jsonEncoder.nextEncoder = encoder;
    
    //
    RHSocketJSONSerializationDecoder *jsonDecoder = [[RHSocketJSONSerializationDecoder alloc] init];
    
    RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
    stringDecoder.nextDecoder = jsonDecoder;
    
    RHSocketBase64Decoder *base64Decoder = [[RHSocketBase64Decoder alloc] init];
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiter = 0x0a;//0x0a，换行符
    decoder.nextDecoder = stringDecoder;//base64Decoder;
    
    //
    _channel = [[RHSocketChannel alloc] initWithHost:host port:port];
    _channel.delegate = self;
    _channel.encoder = jsonEncoder;//base64Encoder;//stringEncoder;
    _channel.decoder = decoder;
    [_channel openConnection];
    
}

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"channelOpened: %@:%d", host, port);
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = [@"{\"key\":\"RHSocketDelimiterEncoder\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [channel asyncSendPacket:req];
    
    req = [[RHSocketPacketRequest alloc] init];
    req.object = @"{\"key\":\"RHSocketStringEncoder\"}";
    [channel asyncSendPacket:req];
    
    req = [[RHSocketPacketRequest alloc] init];
    req.object = @{@"key":@"RHSocketJSONSerializationEncoder"};
    [channel asyncSendPacket:req];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    RHSocketLog(@"channelClosed: %@", error.description);
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"received: %@", [packet object]);
}

#pragma mark - socket service test

- (void)doTestServiceButtonAction
{
    NSString *host = @"www.baidu.com";
    int port = 80;
    
    RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
    
    RHSocketHttpDecoder *decoder = [[RHSocketHttpDecoder alloc] init];
    decoder.nextDecoder = stringDecoder;
    
    [RHSocketService sharedInstance].encoder = [[RHSocketHttpEncoder alloc] init];
    [RHSocketService sharedInstance].decoder = decoder;
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
}

- (void)detectSocketServiceState:(NSNotification *)notif
{
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        RHSocketHttpRequest *req = [[RHSocketHttpRequest alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    } else {
        //
    }//if
}

- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    NSLog(@"detectSocketPacketResponse: %@", notif);
    
    NSDictionary *userInfo = notif.userInfo;
    RHSocketHttpResponse *rsp = userInfo[@"RHSocketPacket"];
    NSLog(@"detectSocketPacketResponse: %@", [rsp object]);
}

#pragma mark - channel proxy test

- (void)doTestProxyButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 7878;
    
    //
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    //
    RHSocketJSONSerializationDecoder *jsonDecoder = [[RHSocketJSONSerializationDecoder alloc] init];
    
    RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
    stringDecoder.nextDecoder = jsonDecoder;
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = stringDecoder;
    
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    connect.successBlock = ^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket>response) {
        @strongify(self);
        [self sendVariableLengthRPC];
    };
    [RHSocketChannelProxy sharedInstance].encoder = encoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendVariableLengthRPC
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    //测试代码，默认为0，未做修改
    NSData *tempData = [@"可变数据包通信测试（包长＋包体数据）" dataUsingEncoding:NSUTF8StringEncoding];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = tempData;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    callReply.successBlock = ^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket>response) {
        RHSocketLog(@"response: %@", [response object]);
    };
    callReply.failureBlock = ^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    };
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
    //只发送，不等待返回
//    [[RHSocketChannelProxy sharedInstance] asyncNotify:callReply];
}

@end
