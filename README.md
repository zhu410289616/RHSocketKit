# RHSocketKit
socket网络通信框架

# CocoaPods
pod 'RHSocketKit'

# log

## 2015-12-22
1-对调整后的框架做扩展，增加rpc处理逻辑。<br/>
2-整理测试代码。<br/>
3-增加tag，提交2.0.0版本（pod 'RHSocketKit', '~> 2.0.0'）。<br/>

## 2015-12-18
1-原有框架中，编码器和解码器在不同的文件中，虽然成对，但是不够一目了然，统一整合到编码解码器codec中。<br/>
2-去除packet中的tag，替换为pid，避免和socket中的tag混淆，为后面的roc做准备。<br/>
3-在connection基础上做一次chanenl封装，将原来拼包的内容，放到channel的buffer中，使得编码解码器更单一，只需要关心编码和解码。<br/>
4-文件命名和结构调整，整体框架看起来更加清晰。<br/>

## 旧框架(tag－1.0.7，已经保留在分支中)
http://blog.csdn.net/zhu410289616/article/details/46731605<br/>
http://blog.csdn.net/zhu410289616/article/details/46739019<br/>
http://blog.csdn.net/zhu410289616/article/details/46746683<br/>

![github](https://github.com/zhu410289616/RHSocketKit/blob/master/Docs/RHSocketUML.png "github") 

# 联系方式
qq:        410289616<br/>
email:     zhu410289616@163.com<br/>
qq群:      330585393<br/>
