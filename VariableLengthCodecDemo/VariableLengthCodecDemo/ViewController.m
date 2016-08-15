//
//  ViewController.m
//  VariableLengthCodecDemo
//
//  Created by zhuruhong on 16/6/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHSocketService.h"
#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"
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
    [_serviceTestButton setTitle:@"Test Variable Length Codec" forState:UIControlStateNormal];
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
    
    //设置心跳定时器间隔15秒
    connectParam.heartbeatInterval = 15;
    
    //设置短线后是否自动重连
    connectParam.autoReconnect = YES;
    
    //变长编解码。包体＝包头（包体的长度）＋包体数据
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    
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
        req.object = [@"变长编码器和解码器测试数据包1" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"变长编码器和解码器测试数据包20" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"变长编码器和解码器测试数据包300" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002be58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 31>
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002ce58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 3230>
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002de58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 333030>
        //观察发送的数据，其实就是把获取object的长度当做［包头］，然后再接上［包体］，发送就ok了
        //3个包的长度分别是，002b，002c，002d，都在sendData的最前面两个字节［包头］
        //后面就是包体，前面都是一样的，就是1，20，300的数据的区别
        
        //解码<002be58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 31>
        //例如得到上面这数据值后，先读区包头的长度字节，为002b。将002b转为10进制就是43，然后读区后续的43个字节，就是包体的内容。
        //这样一个包就解码完成了。
        
    } else {
        //
    }//if
}

- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    NSLog(@"detectSocketPacketResponse: %@", notif);
    
    //这里结果，记得观察打印的内容
    NSDictionary *userInfo = notif.userInfo;
    RHSocketPacketResponse *rsp = userInfo[@"RHSocketPacket"];
    NSLog(@"detectSocketPacketResponse data: %@", [rsp object]);
    NSLog(@"detectSocketPacketResponse string: %@", [rsp stringWithPacket]);
}

@end
