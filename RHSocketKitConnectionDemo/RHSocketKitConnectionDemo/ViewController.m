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

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"

#import "RHSocketPacketContext.h"

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
    [_serviceTestButton setTitle:@"Test Service" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
}

- (void)doTestServiceButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    RHSocketDelimiterEncoder *encoder = [[RHSocketDelimiterEncoder alloc] init];
    encoder.delimiter = 0x0a;//0x0a，换行符
    
    RHSocketDelimiterDecoder *decoder = [[RHSocketDelimiterDecoder alloc] init];
    decoder.delimiter = 0x0a;//0x0a，换行符
    
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
}

- (void)detectSocketServiceState:(NSNotification *)notif
{
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"socket连接测试发送数据" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    } else {
        //
    }//if
}

- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    NSLog(@"detectSocketPacketResponse: %@", notif);
    
    NSDictionary *userInfo = notif.userInfo;
    RHSocketPacketResponse *rsp = userInfo[@"RHSocketPacket"];
    NSLog(@"detectSocketPacketResponse data: %@", [rsp object]);
    NSLog(@"detectSocketPacketResponse content: %@", [[NSString alloc] initWithData:[rsp object] encoding:NSUTF8StringEncoding]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
