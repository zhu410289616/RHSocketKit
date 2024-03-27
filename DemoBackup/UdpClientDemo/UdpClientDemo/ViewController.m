//
//  ViewController.m
//  UdpClientDemo
//
//  Created by zhuruhong on 16/6/8.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketUdpConnection.h"

@interface ViewController ()

@property (nonatomic, strong, retain) UIButton *serviceTestButton;

@property (nonatomic, strong, readonly) RHSocketUdpConnection *udpConnection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, 120, 250, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test udp socket" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
    //
    _udpConnection = [[RHSocketUdpConnection alloc] init];
    [_udpConnection setupUdpSocket];
    
}

- (void)doTestServiceButtonAction
{
    NSString *msg = @"udp socket test～";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSString *host = @"127.0.0.1";
    int port = 20166;
    [_udpConnection sendData:data toHost:host port:port];
}

@end
