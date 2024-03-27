//
//  ViewController.m
//  ProtobufCodecDemo
//
//  Created by zhuruhong on 16/6/8.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHSocketService.h"

#import "RHSocketUtils+Protobuf.h"
#import "RHProtobufVarint32LengthEncoder.h"
#import "RHProtobufVarint32LengthDecoder.h"
#import "RHBaseMessage.pb.h"
#import "Person.pb.h"

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
    [_serviceTestButton setTitle:@"Test Protobuf Codec" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestProtobufCodecButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
}

- (void)doTestProtobufCodecButtonAction
{
    //方便多次观察，先停止之前的连接
    [[RHSocketService sharedInstance] stopService];
    
    //这里的服务器对应RHSocketServerDemo，连接之前，需要运行RHSocketServerDemo开启服务端监听。
    //RHSocketServerDemo服务端只是返回数据，收到的数据是原封不动的，用来模拟发送给客户端的数据。
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //protocol buffer
    RHProtobufVarint32LengthEncoder *encoder = [[RHProtobufVarint32LengthEncoder alloc] init];
    RHProtobufVarint32LengthDecoder *decoder = [[RHProtobufVarint32LengthDecoder alloc] init];
    
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
        Person *person = [[[[Person builder] setId:123] setName:@"哈哈name"] build];
        RHBaseMessage *msg = [[[[[RHBaseMessage builder] setProtobufType:1] setProtobufClassName:@"Person"] setProtobufData:[person data]] build];
        
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = [msg data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        //protobuf对数据做了压缩，在传输多个被压缩过的数据对象时，接收端不能确定实用那种对象解压缩。
        //两种方法，1-多个编解码器结合，protobuf只用来做数据压缩。2-只使用protobuf编解码器，数据协议实用嵌套结构。
        //这里演示了第二种方法，第一种方法在example中。
        //外层为固定的protobuf结构，其中有第二层protobuf结构的数据类型，告知接收端当前压缩的数据为那种结构。
        //例如这里的，外层是RHBaseMessage对象，里面定义了type和data。data中存放Person的data。
        //得到外层固定的RHBaseMessage数据后，通过type得到data中的数据类型，然后对应解压缩data。
        
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
    
    RHBaseMessage *msg = [RHBaseMessage parseFromData:[rsp object]];
    NSLog(@"protobuf[%d]: %@", msg.protobufType, msg.protobufClassName);
    
    if (msg.protobufType == 1) {
        //根据类型解码protobuf的数据
        Person *person = [Person parseFromData:msg.protobufData];
        NSLog(@"person: %@", person.name);
    }
    
}

@end
