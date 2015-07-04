//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketHttpService.h"
#import "RHSocketHttpEncoder.h"
#import "RHSocketHttpDecoder.h"
#import "RHPacketHttpRequest.h"

@interface ViewController ()

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
    
    NSString *host = @"www.baidu.com";
    int port = 80;
    
    [RHSocketHttpService sharedInstance].encoder = [[RHSocketHttpEncoder alloc] init];
    [RHSocketHttpService sharedInstance].decoder = [[RHSocketHttpDecoder alloc] init];
    [[RHSocketHttpService sharedInstance] startServiceWithHost:host port:port];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
