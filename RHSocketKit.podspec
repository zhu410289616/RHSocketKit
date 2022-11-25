Pod::Spec.new do |s|

  s.name         = "RHSocketKit"
  s.version      = "2.3.7"
  s.summary      = "A socket kit based on CocoaAsyncSocket."
  s.homepage     = "https://github.com/zhu410289616/RHSocketKit"
  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author       = { "zhu410289616" => "zhu410289616@163.com" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/zhu410289616/RHSocketKit.git", :tag => s.version.to_s }

  s.default_subspec = "Core"

  s.subspec "Core" do |cs|
    cs.dependency 'CocoaAsyncSocket'
    cs.source_files = "RHSocketKit/Core/**/*" 
    cs.requires_arc = true
  end

  s.subspec "Extend" do |cs|
    cs.dependency "RHSocketKit/Core"
    cs.source_files = "RHSocketKit/Extend/*.{h,m}"
    cs.requires_arc = true 
  end

  s.subspec "CodecExt" do |cs|
    cs.dependency "RHSocketKit/Core"
    cs.source_files = "RHSocketKit/Extend/Codec/*/*.{h,m}"
    cs.requires_arc = true
  end

  s.subspec "RPC" do |cs|
    cs.dependency "RHSocketKit/Core"
    cs.dependency 'MSWeakTimer', '~> 1.1.0'
    cs.source_files = "RHSocketKit/RPC/*.{h,m}", "RHSocketKit/RPC/CallReply/*.{h,m}"
    cs.requires_arc = true
  end

end
