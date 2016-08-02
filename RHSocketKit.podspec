Pod::Spec.new do |s|

  s.name         = "RHSocketKit"
  s.version      = "2.1.8"
  s.summary      = "A socket kit based on CocoaAsyncSocket."
  s.homepage     = "https://github.com/zhu410289616/RHSocketKit"
  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author       = { "zhu410289616" => "zhu410289616@163.com" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/zhu410289616/RHSocketKit.git", :tag => s.version.to_s }

  s.default_subspec = "Core", "Extend"

  s.subspec "Core" do |cs|
    cs.dependency 'CocoaAsyncSocket', '~> 7.4.3'
    cs.dependency 'ProtocolBuffers', '~> 1.9.9.2'
    cs.source_files  = "RHSocketKit/Core/*.{h,m}", "RHSocketKit/Core/{Channel,Codec,Exception,Packet,Utils}/*.{h,m}", "RHSocketKit/Core/Codec/{Delimiter,Protobuf,VariableLength}/*.{h,m}" 
    cs.requires_arc = true
  end

  s.subspec "Extend" do |cs|
    cs.dependency "RHSocketKit/Core"
    cs.source_files = "RHSocketKit/Extend/*.{h,m}", "RHSocketKit/Extend/Codec/{Base64Codec,ProtobufCodec,SerializationCodec,StringCodec}/*.{h,m}"
    cs.requires_arc = true 
  end

  s.subspec "RPC" do |cs|
    cs.dependency "RHSocketKit/Core"
    cs.dependency 'MSWeakTimer', '~> 1.1.0'
    cs.source_files = "RHSocketKit/RPC/*.{h,m}", "RHSocketKit/RPC/CallReply/*.{h,m}"
    cs.requires_arc = true
  end

end
