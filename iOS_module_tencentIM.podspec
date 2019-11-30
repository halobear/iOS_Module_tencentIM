Pod::Spec.new do |s|
  s.name         = "iOS_module_tencentIM"
  s.version      = "1.0.0"
  s.summary      = "幻熊在线聊天系统"
  s.homepage     = "https://github.com/halobear/iOS_module_tencentIM.git"
  s.license      = "MIT"
  s.author       = { "liujidan" => "liujidanjob@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/halobear/iOS_module_tencentIM.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.source_files = "TencentIM/*.{h,m}"

end
