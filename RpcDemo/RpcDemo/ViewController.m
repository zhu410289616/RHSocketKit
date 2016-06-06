//
//  ViewController.m
//  RpcDemo
//
//  Created by zhuruhong on 16/6/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"

#import "RHSocketRpcCmdEncoder.h"
#import "RHSocketRpcCmdDecoder.h"

#import "RHSocketChannelProxy.h"
#import "RHConnectCallReply.h"
#import "EXTScope.h"

@interface ViewController ()

@property (nonatomic, strong, readonly) UIButton *rpcTestButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _rpcTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rpcTestButton.frame = CGRectMake(20, 120, 250, 40);
    _rpcTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _rpcTestButton.layer.borderWidth = 0.5;
    _rpcTestButton.layer.masksToBounds = YES;
    [_rpcTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_rpcTestButton setTitle:@"Test RPC" forState:UIControlStateNormal];
    [_rpcTestButton addTarget:self action:@selector(doTestRpcButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rpcTestButton];
    
}

- (void)doTestRpcButtonAction
{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //cmdEncoder -> VariableLengthEncoder
    //1-先调用的是cmdEncoder编码，就是把pid序列化成二进制，并放到协议的指定位置。我这里是把pid转成4个字节的二进制，然后和object组合，变成数据包中新的object。
    //2-接着调用的是VariableLengthEncoder编码，把计算object的长度，然后组成到数据包的最前面发送。这一步其实就是RHSocketVariableLengthCodecDemo的内容。
    //我这里的设计就是可以根据需要，组装多个编码器，做不同需求的封装。
    //类似装包裹一样，比如把衣服用塑料袋装好，然后外面再套一个纸箱子。还可以继续再做其他包装等等。
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    RHSocketRpcCmdEncoder *cmdEncoder = [[RHSocketRpcCmdEncoder alloc] init];
    cmdEncoder.nextEncoder = encoder;
    
    //VariableLengthDecoder -> cmdDecoder
    //这里和编码刚好是相反的。1-先按照VariableLengthDecoder变长协议解码，得到数据包内容。
    //2-数据包中，还有一个pid的字段，利用cmdDecoder解码得到pid数据（这个pid数据需要服务端针对请求的pid返回）。
    //3-得到pid数据后，我们再从本地的RHSocketCallReply记录中，得到对应的RHSocketCallReply对象。
    //4-回调RHSocketCallReply对象的SuccessBlock或FailureBlock。
    RHSocketRpcCmdDecoder *cmdDecoder = [[RHSocketRpcCmdDecoder alloc] init];
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = cmdDecoder;
    
    [RHSocketChannelProxy sharedInstance].encoder = cmdEncoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //连接服务器的逻辑，也封装成对象，利用RHConnectCallReply处理，同其他CallReply保持一致。
    //连接成功后，我们做后续的调用逻辑。
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    //weak和strong是为了防止循环引用，这个库EXTScope还是很好用的。
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpc];
    }];
    [connect setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"connect error: %@", error.description);
    }];
    //执行连接请求
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
    
    /*
     连接记录
     2016-04-05 20:13:45.212 RHSocketRpcSimpleDemo[22644:2004206] [RHSocketConnection] didConnectToHost: 127.0.0.1, port: 20162
     2016-04-05 20:13:45.213 RHSocketRpcSimpleDemo[22644:2004206] RHConnectCallReply onSuccess: (null)
     */
    
    /*
     连接服务器成功后，组装数据包发送。
     sendData中的数据：
     1-前两个字节0043为长度。
     2-后面跟着的四个字节e703 0000为pid的二进制数据，这里是低位在前高位在后的，也就是0000037e的反序，37e就是999的16进制。
     3-在后面就是object的数据内容了。
     2016-04-05 20:13:45.213 RHSocketRpcSimpleDemo[22644:2004206] timeout: -1.000000, sendData: <0043e703 0000e688 91e698af e695b0e6 8daee586 85e5aeb9 e38082e6 8891e698 afe695b0 e68daee5 8685e5ae b9e38082 e68891e6 98afe695 b0e68dae e58685e5 aeb9e380 82>
     2016-04-05 20:13:45.213 RHSocketRpcSimpleDemo[22644:2004206] [RHSocketConnection] didWriteDataWithTag: 0
     */
    
    
    /*
     echo服务器是原封不懂的返回的，依旧是上面发送出去的数据，69个字节，执行解码过程。
     1-先读区2个字节的长度，0043，即67是后面的数据内容。
     2-读取67个字节的前4个字节，解码得到pid内容，然后保存到RHDownstreamPacket的pid中。
     3-将后面的63个字节直接保存到RHDownstreamPacket的object中，解码完成。
     4-RHSocketChannelProxy在得到解码完成的RHDownstreamPacket后，通过pid从_callReplyManager中取出之前记录的请求CallReply，触发block回调。
     2016-04-05 20:13:45.217 RHSocketRpcSimpleDemo[22644:2004206] [RHSocketConnection] didReadData length: 69, tag: 0
     2016-04-05 20:13:45.217 RHSocketRpcSimpleDemo[22644:2004206] RHSocketCallReply onSuccess: <e68891e6 98afe695 b0e68dae e58685e5 aeb9e380 82e68891 e698afe6 95b0e68d aee58685 e5aeb9e3 8082e688 91e698af e695b0e6 8daee586 85e5aeb9 e38082>
     2016-04-05 20:13:45.217 RHSocketRpcSimpleDemo[22644:2004206] protobuf response: 我是数据内容。我是数据内容。我是数据内容。
     */
    
    //以上是正常的请求回调过程，如果请求超时一直未返回，就需要有超时机制。
    //在_callReplyManager中有一个定时器，定时检查记录的CallReply是否超时。而超时的时间则是通过RHSocketPacketRequest中的timeout设置了。
}

- (void)sendRpc
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.pid = 999;//这里的pid就是请求和返回的一对一标记，这里999只是测试，直接写死。正真使用需要定义一个唯一值生成器
    req.object = [@"我是数据内容。我是数据内容。我是数据内容。" dataUsingEncoding:NSUTF8StringEncoding];
    
    //将请求数据包，封装到CallReply中，等到Call。服务端Reply后，通过block返回response。
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        RHSocketLog(@"protobuf response: %@", [[NSString alloc] initWithData:[response object] encoding:NSUTF8StringEncoding]);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

@end
