//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketChannel.h"
#import "RHSocketChannel+Heartbeat.h"

#import "RHSocketStringEncoder.h"
#import "RHSocketStringDecoder.h"

#import "RHSocketBase64Encoder.h"
#import "RHSocketBase64Decoder.h"

#import "RHSocketJSONSerializationEncoder.h"
#import "RHSocketJSONSerializationDecoder.h"

#import "Person.pb.h"

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

#import "RHSocketRpcCmdEncoder.h"
#import "RHSocketRpcCmdDecoder.h"

//
#import "RHSocketUtils.h"

//
#import "RHSocketByteBuf.h"

//
#import "RHSocketUtils+Protobuf.h"
#import "RHProtobufVarint32LengthEncoder.h"
#import "RHProtobufVarint32LengthDecoder.h"
#import "RHBaseMessage.pb.h"

@interface ViewController () <RHSocketChannelDelegate>

@property (nonatomic, strong) UIButton *channelTestButton;
@property (nonatomic, strong) UIButton *serviceTestButton;
@property (nonatomic, strong) UIButton *proxyTestButton;

@property (nonatomic, strong) UIButton *jsonTestButton;
@property (nonatomic, strong) UIButton *base64TestButton;
@property (nonatomic, strong) UIButton *protobufTestButton;
@property (nonatomic, strong) UIButton *protobufCodecTestButton;

@property (nonatomic, strong) RHSocketChannelDefault *channel;

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
    _channelTestButton.frame = CGRectMake(20, 40, 250, 40);
    _channelTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _channelTestButton.layer.borderWidth = 0.5;
    _channelTestButton.layer.masksToBounds = YES;
    [_channelTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_channelTestButton setTitle:@"Test Channel" forState:UIControlStateNormal];
    [_channelTestButton addTarget:self action:@selector(doTestChannelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_channelTestButton];
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, CGRectGetMaxY(_channelTestButton.frame) + 20, 250, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test Service" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
    _proxyTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _proxyTestButton.frame = CGRectMake(20, CGRectGetMaxY(_serviceTestButton.frame) + 20, 250, 40);
    _proxyTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _proxyTestButton.layer.borderWidth = 0.5;
    _proxyTestButton.layer.masksToBounds = YES;
    [_proxyTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_proxyTestButton setTitle:@"Test Proxy" forState:UIControlStateNormal];
    [_proxyTestButton addTarget:self action:@selector(doTestProxyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_proxyTestButton];
    
    //配合echo server服务器测试
    _jsonTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _jsonTestButton.frame = CGRectMake(20, CGRectGetMaxY(_proxyTestButton.frame) + 20, 250, 40);
    _jsonTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _jsonTestButton.layer.borderWidth = 0.5;
    _jsonTestButton.layer.masksToBounds = YES;
    [_jsonTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_jsonTestButton setTitle:@"Test Json Codec" forState:UIControlStateNormal];
    [_jsonTestButton addTarget:self action:@selector(doTestJsonCodecButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_jsonTestButton];
    
    _base64TestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _base64TestButton.frame = CGRectMake(20, CGRectGetMaxY(_jsonTestButton.frame) + 20, 250, 40);
    _base64TestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _base64TestButton.layer.borderWidth = 0.5;
    _base64TestButton.layer.masksToBounds = YES;
    [_base64TestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_base64TestButton setTitle:@"Test Base64 Codec" forState:UIControlStateNormal];
    [_base64TestButton addTarget:self action:@selector(doTestBase64CodecButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_base64TestButton];
    
    _protobufTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _protobufTestButton.frame = CGRectMake(20, CGRectGetMaxY(_base64TestButton.frame) + 20, 250, 40);
    _protobufTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _protobufTestButton.layer.borderWidth = 0.5;
    _protobufTestButton.layer.masksToBounds = YES;
    [_protobufTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_protobufTestButton setTitle:@"Test Protobuf And Cmd Codec" forState:UIControlStateNormal];
    [_protobufTestButton addTarget:self action:@selector(doTestProtobufAndCmdCodecButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_protobufTestButton];
    
    _protobufCodecTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _protobufCodecTestButton.frame = CGRectMake(20, CGRectGetMaxY(_protobufTestButton.frame) + 20, 250, 40);
    _protobufCodecTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _protobufCodecTestButton.layer.borderWidth = 0.5;
    _protobufCodecTestButton.layer.masksToBounds = YES;
    [_protobufCodecTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_protobufCodecTestButton setTitle:@"Test Protobuf Codec" forState:UIControlStateNormal];
    [_protobufCodecTestButton addTarget:self action:@selector(doTestProtobufCodecButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_protobufCodecTestButton];
    
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
    
    //protobuf
    Person *person = [[[[Person builder] setId:123] setName:@"name"] build];
    RHSocketLog(@"[person data]: %@", [person data]);
    
    //
    data = [RHSocketUtils dataWithRawVarint32:300];
    RHSocketLog(@"data: %@", data);
    
    value = [RHSocketUtils valueWithVarint32Data:data];
    RHSocketLog(@"value: %ld", value);
    
    //
    RHSocketByteBuf *byteBuf = [[RHSocketByteBuf alloc] init];
    [byteBuf writeInt16:data.length];
    [byteBuf writeData:data];
    RHSocketLog(@"[byteBuf data]: %@", [byteBuf data]);
    [byteBuf writeInt16:hexString.length];
    [byteBuf writeString:hexString];
    RHSocketLog(@"[byteBuf data]: %@", [byteBuf data]);
    
    int16_t len0 = [byteBuf readInt16:0];
    NSData *data0 = [byteBuf readData:2 length:len0];
    RHSocketLog(@"len0: %d, data0: %@", len0, data0);
    int16_t len1 = [byteBuf readInt16:2 + len0];
    NSData *data1 = [byteBuf readData:2 + len0 + 2 length:len1];
    RHSocketLog(@"len1: %d, data1: %@", len1, data1);
    int16_t len2 = [byteBuf readInt16:2 + len0];
    NSString *str2 = [byteBuf readString:2 + len0 + 2 length:len1];
    RHSocketLog(@"len2: %d, data2: %@", len2, str2);
    
}

#pragma mark - channel test

- (void)doTestChannelButtonAction
{
    
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiterData = [@"aaa" dataUsingEncoding:NSUTF8StringEncoding];// [RHSocketUtils CRLFData];//回车换行符\r\n
    
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
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiterData = [@"aaa" dataUsingEncoding:NSUTF8StringEncoding];//[RHSocketUtils CRLFData];//回车换行符\r\n
    decoder.nextDecoder = stringDecoder;//base64Decoder;
    
    //
    if (_channel) {
        [_channel closeConnection];
        _channel = nil;
    }
    //
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = port;
    connectParam.autoReconnect = YES;
    connectParam.heartbeatInterval = 10;//设置心跳间隔10秒
    
    _channel = [[RHSocketChannelDefault alloc] initWithConnectParam:connectParam];
    [_channel addDelegate:self];
    _channel.encoder = jsonEncoder;//base64Encoder;//stringEncoder;
    _channel.decoder = decoder;
    
    /**
     设置心跳包
     (有人问，我这里的object为什么是json格式，其他格式就发送失败。那是因为我上面设置的encoder和decoder组合参数)
     协议不同，传递的数据不同的。可以学习DelimiterCodecDemo和VariableLengthCodecDemo的心跳设置。
     */
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = [@"{\"key\":\"Heartbeat\"}" dataUsingEncoding:NSUTF8StringEncoding];
    _channel.heartbeat = req;
    
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
    
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = port;
    connectParam.heartbeatEnabled = NO;
    
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
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
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendVariableLengthRPC];
    }];
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
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        RHSocketLog(@"response: %@", [response object]);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
    //只发送，不等待返回
    //    [[RHSocketChannelProxy sharedInstance] asyncNotify:callReply];
}

#pragma mark - test json codec

- (void)doTestJsonCodecButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //jsonEncoder -> stringEncoder -> VariableLengthEncoder
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    RHSocketStringEncoder *stringEncoder = [[RHSocketStringEncoder alloc] init];
    stringEncoder.nextEncoder = encoder;
    
    RHSocketJSONSerializationEncoder *jsonEncoder = [[RHSocketJSONSerializationEncoder alloc] init];
    jsonEncoder.nextEncoder = stringEncoder;
    
    //VariableLengthDecoder -> stringDecoder -> jsonDecoder
    RHSocketJSONSerializationDecoder *jsonDecoder = [[RHSocketJSONSerializationDecoder alloc] init];
    
    RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
    stringDecoder.nextDecoder = jsonDecoder;
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = stringDecoder;
    
    [RHSocketChannelProxy sharedInstance].encoder = jsonEncoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestJsonCodec];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendRpcForTestJsonCodec
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    paramDic[@"key1"] = @"1-先做json的编码";
    paramDic[@"key2"] = @"2-接着做string的编码";
    paramDic[@"key3"] = @"3-接着做可变包长度编码";
    paramDic[@"内容1"] = @"可变数据包通信测试（中文测试）";
    paramDic[@"content2"] = @"Variable Length （codec test）";
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = paramDic;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        NSDictionary *resultDic = [response object];
        RHSocketLog(@"json resultDic: %@, %@", resultDic[@"key1"], resultDic[@"key2"]);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

#pragma mark - test base64 codec

- (void)doTestBase64CodecButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //base64Encoder -> VariableLengthEncoder
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    RHSocketBase64Encoder *base64Encoder = [[RHSocketBase64Encoder alloc] init];
    base64Encoder.nextEncoder = encoder;
    
    //VariableLengthDecoder -> base64Decoder
    RHSocketBase64Decoder *base64Decoder = [[RHSocketBase64Decoder alloc] init];
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = base64Decoder;
    
    [RHSocketChannelProxy sharedInstance].encoder = base64Encoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestBase64Codec];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendRpcForTestBase64Codec
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = @"1-先做base64的编码. 2-接着做可变包长度编码";
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        RHSocketLog(@"base64 response: %@", [response object]);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

#pragma mark - test protobuf and cmd codec

- (void)doTestProtobufAndCmdCodecButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //protobufEncoder -> cmdEncoder -> VariableLengthEncoder
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    RHSocketRpcCmdEncoder *cmdEncoder = [[RHSocketRpcCmdEncoder alloc] init];
    cmdEncoder.nextEncoder = encoder;
    
    //VariableLengthDecoder -> cmdDecoder -> protobufDecoder
    
    RHSocketRpcCmdDecoder *cmdDecoder = [[RHSocketRpcCmdDecoder alloc] init];
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = cmdDecoder;
    
    [RHSocketChannelProxy sharedInstance].encoder = cmdEncoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestProtobufAndCmdCodec];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendRpcForTestProtobufAndCmdCodec
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    Person *person = [[[[Person builder] setId:123] setName:@"哈哈name"] build];
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.pid = 999;
    req.object = [person data];
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        RHSocketLog(@"protobuf response: %@", [response object]);
        Person *person = [Person parseFromData:[response object]];
        RHSocketLog(@"person: %@", person.name);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

#pragma mark - test protobuf codec

- (void)doTestProtobufCodecButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //
    RHProtobufVarint32LengthEncoder *encoder = [[RHProtobufVarint32LengthEncoder alloc] init];
    RHProtobufVarint32LengthDecoder *decoder = [[RHProtobufVarint32LengthDecoder alloc] init];
    
    [RHSocketChannelProxy sharedInstance].encoder = encoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestProtobufCodec];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendRpcForTestProtobufCodec
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    Person *person = [[[[Person builder] setId:123] setName:@"哈哈name"] build];
    RHBaseMessage *msg = [[[[[RHBaseMessage builder] setProtobufType:1] setProtobufClassName:@"Person"] setProtobufData:[person data]] build];
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.pid = 0;
    req.object = [msg data];
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        RHSocketLog(@"protobuf response: %@", [response object]);
        
        RHBaseMessage *msg = [RHBaseMessage parseFromData:[response object]];
        RHSocketLog(@"protobuf[%d]: %@", msg.protobufType, msg.protobufClassName);
        
        Person *person = [Person parseFromData:msg.protobufData];
        RHSocketLog(@"person: %@", person.name);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

@end
