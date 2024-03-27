//
//  ViewController.m
//  DelimiterCodecDemo
//
//  Created by zhuruhong on 16/6/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHSocketService.h"
#import "RHSocketDelimiterEncoder.h"
#import "RHSocketDelimiterDecoder.h"
#import "RHSocketUtils.h"

@interface ViewController ()

@property (nonatomic, strong, retain) UIButton *serviceTestButton;

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
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, 120, 250, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test Delimiter Connection" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
}

- (void)doTestServiceButtonAction
{
    //方便多次观察，先停止之前的连接
    [[RHSocketService sharedInstance] stopService];
    
    //这里的服务器对应RHSocketServerDemo，连接之前，需要运行RHSocketServerDemo开启服务端监听。
    //RHSocketServerDemo服务端只是返回数据，收到的数据是原封不动的，用来模拟发送给客户端的数据。
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = host;
    connectParam.port = port;
    
    //设置短线后是否自动重连
    connectParam.autoReconnect = YES;
    
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiterData = [RHSocketUtils dataFromHexString:@"0x0a"];//0x0a，换行符
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiterData = [RHSocketUtils dataFromHexString:@"0x0a"];//0x0a，换行符
    
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    
    //设置心跳包，这里的object数据，和服务端约定好
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = [@"Heartbeat" dataUsingEncoding:NSUTF8StringEncoding];
    [RHSocketService sharedInstance].heartbeat = req;
    
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
}

- (void)detectSocketServiceState:(NSNotification *)notif
{
    //NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    //对应的连接ip和状态数据。_isRunning为YES是连接成功。
    //没有心跳超时后会自动断开。
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        //连接成功后，发送数据包
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"分隔符编码器和解码器测试数据包1" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"分隔符编码器和解码器测试数据包2" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"分隔符编码器和解码器测试数据包3" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        //上面都是一条一条发送的，编码器会自动加上分隔符。服务端返回也是一条一条的。不太容易出现3条一起返回的。
        //这里我们模拟一个几条数据组装在一起返回的。
        NSMutableData *someData = [[NSMutableData alloc] init];
        [someData appendData:[@"第1块数据" dataUsingEncoding:NSUTF8StringEncoding]];
        [someData appendData:[RHSocketUtils dataFromHexString:@"0x0a"]];//手动加入分隔符，模拟几条数据一起的数据块
        [someData appendData:[@"第2块数据" dataUsingEncoding:NSUTF8StringEncoding]];
        [someData appendData:[RHSocketUtils dataFromHexString:@"0x0a"]];//手动加入分隔符，模拟几条数据一起的数据块
        [someData appendData:[@"第3块数据" dataUsingEncoding:NSUTF8StringEncoding]];
        req = [[RHSocketPacketRequest alloc] init];
        req.object = someData;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
    } else {
        //
    }//if
}

- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    NSLog(@"detectSocketPacketResponse: %@", notif);
    
    //从打印日志可以看出来，6个数据块，分成4次发送的。但是返回的数据块却会是几个数据块一起返回的。
    //一起返回的数据块，就需要针对分隔符解码器解析，得到对应的6条数据。类似一句话，需要标点符号来区分一句话的结束。
    //另外也可以看出，tcp的数据包是有序的，按照发送的返回数据依次处理的。
    NSDictionary *userInfo = notif.userInfo;
    RHSocketPacketResponse *rsp = userInfo[@"RHSocketPacket"];
    NSLog(@"detectSocketPacketResponse data: %@", [rsp object]);
    NSLog(@"detectSocketPacketResponse string: %@", [rsp stringWithPacket]);
}

@end
