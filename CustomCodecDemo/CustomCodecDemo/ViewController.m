//
//  ViewController.m
//  CustomCodecDemo
//
//  Created by zhuruhong on 16/6/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHSocketService.h"

#import "RHSocketCustom0330Encoder.h"
#import "RHSocketCustom0330Decoder.h"

#import "RHSocketCustomRequest.h"
#import "RHSocketCustomResponse.h"

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
    [_serviceTestButton setTitle:@"Test Custom Codec" forState:UIControlStateNormal];
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
    
    //变长编解码。包体＝包头（包体的长度）＋包体数据
    RHSocketCustom0330Encoder *encoder = [[RHSocketCustom0330Encoder alloc] init];
    RHSocketCustom0330Decoder *decoder = [[RHSocketCustom0330Decoder alloc] init];
    
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
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
        RHSocketCustomRequest *req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 1234;
        req.object = [@"自定义编码器和解码器测试数据包1" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 12;
        req.object = [@"自定义编码器和解码器测试数据包20" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketCustomRequest alloc] init];
        req.fenGeFu = 0x24;
        req.dataType = 0;
        req.object = [@"自定义编码器和解码器测试数据包300" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
    } else {
        //
    }//if
}

- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    NSLog(@"detectSocketPacketResponse: %@", notif);
    
    //这里结果，记得观察打印的内容
    NSDictionary *userInfo = notif.userInfo;
    RHSocketCustomResponse *rsp = userInfo[@"RHSocketPacket"];
    NSLog(@"detectSocketPacketResponse data: %@", [rsp object]);
    NSLog(@"detectSocketPacketResponse string: %@", [rsp stringWithPacket]);
}

@end
