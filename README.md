## RHSocketKit
[![Build Status](https://travis-ci.org/zhu410289616/RHSocketKit.svg?branch=master)](https://travis-ci.org/zhu410289616/RHSocketKit)
[![Version Status](https://img.shields.io/cocoapods/v/RHSocketKit.svg?style=flat)](http://cocoadocs.org/docsets/RHSocketKit)
[![Analytics](https://ga-beacon.appspot.com/UA-78533289-1/welcome-page)](https://github.com/zhu410289616/RHSocketKit)
[![Platform](http://img.shields.io/cocoapods/p/RHSocketKit.svg?style=flat)](http://cocoapods.org/?q=RHSocketKit)
[![License](https://img.shields.io/cocoapods/l/RHSocketKit.svg)](http://cocoadocs.org/docsets/RHSocketKit)

socket网络通信框架</br>
虽然CocoaAsyncSocket已经非常的成熟，但是项目，业务，协议等不同导致tcp模块的公用性不高，需要根据协议重新订制调整，不能直接拷贝框架使用。
为了减少调整消耗的时间，对tcp模块中相关的内容进行拆分实现。</br>`其中专为和netty通信互通而实现了3个主要编解码器：1-DelimiterBasedFrame。2-LengthFieldBasedFrame。3-ProtobufVarint32Frame。`

## CocoaPods
pod 'RHSocketKit'

## Log
### 2016-06-12
1－server代码也统一管理。</br>
2-增加protobuf编解码器的使用demo。</br>
3－增加udp测试。</br>
4－增加socket中的tls测试。

### 2016-05-27
1－增加针对net的protobuf编码器／解码器。</br>
2－pod版本更新（`pod 'RHSocketKit', '~> 2.1.4'`）。

### 2016-05-20
1－RHSocketConnection增加ipv6的设置，在ipv4和ipv6都存在时，优选ipv6。<br/>
2－pod版本更新（`pod 'RHSocketKit', '~> 2.1.3'`）。

### 2016-05-19
1－修改分隔符编解码器的字节数，可以使用多个字节作为分隔符。<br/>
2－修改RHSocketUtils中的部分转换方法。<br/>
3－pod版本更新（`pod 'RHSocketKit', '~> 2.1.2'`）。

### 2016-04-05
####下面的3和4是最基本，最简单的使用了。2相对要求高点，需要理解应用中传输协议的内容，需要懂得把场景需求转化为传输编码。1是高层级的封装，还是看源码吧。
1－增加rpc使用demo，里面有写调用过程的说明和日志。<br/>
2－增加自定义编码器和解码器的使用demo。<br/>
3－增加变长编码解码器的使用demo。<br/>
4－增加分隔符编码解码器的使用demo。<br/>
5－增加RHSocketKit连接服务器的demo。

### 2016-03-17
1－针对rpc的场景，增加命令字段编码解码，处理rpc的call和reply的数据一一对应<br/>
2－修正底层通道中的粘包bug。非常感谢网友［狙击手］的反馈，不愧为狙击手。<br/>
3－pod版本更新（`pod 'RHSocketKit', '~> 2.1.0'`）。

### 2016-02-23
1－增加异常输出信息，明确输出异常原因。<br/>
2－使用责任链模式，调整codec的逻辑，方便编解码的分工协作。增加的编解码包括：**`字符串编解码，json编解码，base64编解码，protobuf编解码`**。<br/>
3－增加编解码的测试用例和配套的echo服务器demo。<br/>
4－pod版本更新（`pod 'RHSocketKit', '~> 2.0.8'`）。<br/>
5－protobuf使用：<http://blog.csdn.net/zhu410289616/article/details/50739164>

### 2016-01-28
1－应网友要求，`对core中的核心类增加注释说明`。<br/>
2－数据传输过程中，经常有不同数据类型和字节之间的转换，盗用他人转换方法，并增加可以动态调整字节长度的方法。<br/>
3－调整可变长度的编码解码器，使用新的数值／字节转换方法，`可以调整头部长度字节的个数`。<br/>
4－增加RPC的注释说明，并**`明确codec编码解码器和netty中解码器的对应关系`**，降低网友疑虑。<br/>
5－调整RPC的回调方法，使用block实现，方便逻辑调用处理。<br/>
6－pod版本更新（`pod 'RHSocketKit', '~> 2.0.3'`）。

### 2015-12-23
1-增加数值和字节互相转换的方法。<br/>
2-修改可变长度解码的bug。<br/>
3-调整rpc框架的目录结构，防止无效引入。<br/>
4-提交2.0.1版本。通过pod 'RHSocketKit', '~> 2.0.1'时，默认只包含Core和Extend。rpc框架引入方式：pod 'RHSocketKit/RPC', '~> 2.0.1'。

### 2015-12-22
1-对调整后的框架做扩展，增加rpc处理逻辑。<br/>
2-整理测试代码。<br/>
3-增加tag，提交2.0.0版本（pod 'RHSocketKit', '~> 2.0.0'）。<br/>

### 2015-12-18
1-原有框架中，编码器和解码器在不同的文件中，虽然成对，但是不够一目了然，统一整合到编码解码器codec中。<br/>
2-去除packet中的tag，替换为pid，避免和socket中的tag混淆，为后面的roc做准备。<br/>
3-在connection基础上做一次chanenl封装，将原来拼包的内容，放到channel的buffer中，使得编码解码器更单一，只需要关心编码和解码。<br/>
4-文件命名和结构调整，整体框架看起来更加清晰。<br/>

### 2015-08-24
tag－1.0.7，已经保留在分支中


## Features
框架的设计运用了一些设计模式，通过组合和协议编程，灵活多变，扩展方便。</br>
`目前框架的核心在core目录中，主要组件有connection，channel，packet，codec，exception，utils，其中codec的实现是业务重点。`</br>
另外，RHSocketService是一个单例实现，方便直接调用。RPC是一个深度封装的内容，需要理解框架才能使用。


### RHSocketConnection
```
socket网络连接对象，只负责socket网络的连接通信，内部使用GCDAsyncSocket。
1-只公开GCDAsyncSocket的主要方法，增加使用的便捷性。
2-封装的另一个目的是，易于后续更新调整。如果不想使用GCDAsyncSocket，只想修改内部实现即可，对外不产生影响。
```

### RHSocketChannel
```
在RHSocketConnection基础上做封装，负责对socket中的二进制通讯数据做缓存、粘包，内部需要编码、解码处理。
1-需要有一个编码解码器，对数据块做封包和解包。很多人不理解这个，其实很简单。比如一句话里面没有标点符号你怎么知道什么时候是结束什么时候开始呢
2-内部带有一个数据缓存，用于对数据的拼包。发送网络数据时，一条数据会被切成多个网络包［不是我们上层协议中的概念］，需要对收到的数据做合并，完整后才能正常解码。
```

### Packet-数据包协议
```
/**
 *  数据包协议
 */
@protocol RHSocketPacket <NSObject>

@required

/**
 *  数据包携带的数据变量（可以是任何数据格式）
 */
@property (nonatomic, strong) id object;

@optional

/**
 *  类似tag，必要的时候实现，用于区分某个数据包
 */
@property (nonatomic, assign) NSInteger pid;

- (instancetype)initWithObject:(id)aObject;

@end
```

```
/**
 *  上行数据包协议，发送数据时，必须遵循的协议
 */
@protocol RHUpstreamPacket <RHSocketPacket>

@optional

/**
 *  发送数据超时时间，必须设置。－1时为无限等待
 */
@property (nonatomic, assign) NSTimeInterval timeout;

@end
```

```
/**
 *  下行数据包协议，接收数据时，必须遵循的协议
 */
@protocol RHDownstreamPacket <RHSocketPacket>

@end
```

### Codec－编码器encoder和解码器decoder
`编码器和解码器是应用传输协议直接相关的重点，简单的有：`

* 分隔符编码器RHSocketDelimiterEncoder和解码器RHSocketDelimiterDecoder。
* 可变长度编码器RHSocketVariableLengthEncoder和解码器RHSocketVariableLengthDecoder。

为了保证数据安全，一般都会在协议上做一些特殊定义，防止被恶意访问，所以自定义协议是必须的。框架的编码和解码协议如下，可以自由实现，满足需求。demo可以查看RHSocketCustomCodecDemo和基于本框架的RHMQTTKit。

```
/**
 *  编码器协议
 */
@protocol RHSocketEncoderProtocol <NSObject>

@required

/**
 *  编码器
 *
 *  @param packet 待发送的数据包
 *  @param output 数据编码后，分发对象
 */
- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output;

@end
```

```
/**
 *  解码器协议
 */
@protocol RHSocketDecoderProtocol <NSObject>

/**
 *  解码器
 *
 *  @param downstreamPacket 接收到的原始数据
 *  @param output           数据解码后，分发对象
 *
 *  @return -1解码异常，断开连接; 0数据不完整，等待数据包; >0解码正常，为已解码数据长度
 */
- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output;

@end
```

## Usage
### 变长编码器和解码器demo
```
- (void)doTestServiceButtonAction
{
    //方便多次观察，先停止之前的连接
    [[RHSocketService sharedInstance] stopService];
    
    //这里的服务器对应RHSocketServerDemo，连接之前，需要运行RHSocketServerDemo开启服务端监听。
    //RHSocketServerDemo服务端只是返回数据，收到的数据是原封不动的，用来模拟发送给客户端的数据。
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
    //变长编解码。包体＝包头（包体的长度）＋包体数据
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    
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
    NSLog(@"detectSocketPacketResponse string: %@", [[NSString alloc] initWithData:[rsp object] encoding:NSUTF8StringEncoding]);
}
```
### 自定义编码器和解码器
<http://blog.csdn.net/zhu410289616/article/details/51182751>

### Blog
<http://blog.csdn.net/zhu410289616/article/details/46731605><br/>
<http://blog.csdn.net/zhu410289616/article/details/46739019><br/>
<http://blog.csdn.net/zhu410289616/article/details/46746683><br/>
<http://blog.csdn.net/zhu410289616/article/details/49331323><br/>
<http://blog.csdn.net/zhu410289616/article/details/50739164><br/>

## Video
框架简述：<http://www.tudou.com/programs/view/OahFYRBIFJA/>

## 联系方式
qq:        410289616<br/>
email:     <zhu410289616@163.com><br/>
qq群:      330585393<br/>
