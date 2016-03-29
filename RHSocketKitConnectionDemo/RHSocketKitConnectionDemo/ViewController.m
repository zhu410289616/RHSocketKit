//
//  ViewController.m
//  RHSocketKitConnectionDemo
//
//  Created by zhuruhong on 16/3/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketService.h"

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketDelimiterDecoder.h"

@interface ViewController ()
{
    UIButton *_serviceTestButton;
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
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, 120, 250, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test Connection" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
}

- (void)doTestServiceButtonAction
{
    NSString *host = @"www.baidu.com";
    int port = 80;
    
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiter = 0x0a;//0x0a，换行符
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiter = 0x0a;//0x0a，换行符
    
    //完整的socket传输数据，必须有定义应用的数据传输协议，也就必须设置一个对应的编码器和解码器。
    //这里只是初始化，对于连接测试没有实际作用。
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    
    //连接测试，没有额外交换，
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
}

- (void)detectSocketServiceState:(NSNotification *)notif
{
    //NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    //对应的连接ip和状态数据。_isRunning为YES是连接成功。
    //没有心跳超时后会自动断开。
    NSLog(@"detectSocketServiceState: %@", notif);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
