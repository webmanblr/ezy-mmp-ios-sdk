Pod::Spec.new do |s|
  s.name             = 'EzyMMP'
  s.version          = '1.0.2'
  s.summary          = 'A lightweight iOS SDK for attributing app installs and tracking events with EzyURL.'
  s.homepage         = 'https://ezyurl.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EzyURL Team' => 'support@ezyurl.io' }
  s.source           = { :git => 'https://github.com/webmanblr/ezy-mmp-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Sources/EzyMMP/**/*'
  s.frameworks       = 'UIKit', 'Foundation'
end
