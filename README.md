## RHSocketKit
socket网络通信框架

## CocoaPods
pod 'RHSocketKit'

## Log
### 2016-02-23
1－增加异常输出信息，明确输出异常原因。<br/>
2－使用责任链模式，调整codec的逻辑，方便编解码的分工协作。增加的编解码包括：**`字符串编解码，json编解码，base64编解码，protobuf编解码`**。<br/>
3－增加编解码的测试用例和配套的echo服务器demo。<br/>
4－pod版本更新（`pod 'RHSocketKit', '~> 2.0.8'`）。

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

### 旧框架(tag－1.0.7，已经保留在分支中)
http://blog.csdn.net/zhu410289616/article/details/46731605<br/>
http://blog.csdn.net/zhu410289616/article/details/46739019<br/>
http://blog.csdn.net/zhu410289616/article/details/46746683<br/>

## 联系方式
qq:        410289616<br/>
email:     zhu410289616@163.com<br/>
qq群:      330585393<br/>
