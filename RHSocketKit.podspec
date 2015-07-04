Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "RHSocketKit"
  s.version      = "1.0.4"
  s.summary      = "A socket kit based on CocoaAsyncSocket."
  s.homepage     = "https://github.com/zhu410289616/RHSocketKit"
  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author             = { "zhu410289616" => "zhu410289616@163.com" }

  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.source       = { :git => "https://github.com/zhu410289616/RHSocketKit.git", :tag => "#{s.version}" }
  s.source_files  = "RHSocketKit/Extend/*.{h,m}", "RHSocketKit/Core/*.{h,m}"
  s.requires_arc = true
  s.dependency 'CocoaAsyncSocket', '~> 7.4.1' #项目依赖的其他库，如果有多个需要填写多个s.dependency

end
