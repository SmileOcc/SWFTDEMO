#
# Be sure to run `pod lib lint YXKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YXKit'
  s.version          = '1.8.0'
  s.summary          = '友信证券通用组件-YXKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.baidu.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ellison' => 'fudiyu@youxin.com' }
  s.source           = { :git => 'ssh://git@szgitlab.youxin.com:222/YXPods/YXKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  #指定swift版本号
  s.pod_target_xcconfig = {'SWIFT_VERSION'=>'5.0'}
  s.swift_version = '5.0'
  s.static_framework = true
  #s.source_files = 'YXKit/YXKit.h'

  #s.source_files = 'YXKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YXKit' => ['YXKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  #s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
      ss.source_files = 'YXKit/YXKit.h'
  end

  s.subspec 'YXAlertView' do |ss|
      ss.source_files = 'YXKit/Classes/YXAlertView'
      ss.dependency 'YXKit/Core'
      ss.dependency 'YXKit/YXConstant'
      ss.dependency 'YXKit/YXSnapKit'      
      ss.dependency 'TYAlertController', '~> 1.2.0'
      ss.dependency 'RxSwift'
      ss.dependency 'RxCocoa'
  end

  s.subspec 'YXConstant' do |ss|
      ss.source_files = 'YXKit/Classes/YXConstant', 'YXKit/Classes/YXConstant/Vendor/MiniFlaker'
      ss.dependency 'YXKit/Core'
      ss.dependency 'YXKit/YXUtils'

      ss.dependency 'SAMKeychain'
      ss.dependency 'CryptoSwift', '1.4.2'
      ss.dependency 'MMKV', '1.0.23'
  end

  s.subspec 'YXSnapKit' do |ss|
      ss.source_files = 'YXKit/Classes/YXSnapKit'
      ss.dependency 'YXKit/Core'
      ss.dependency 'SnapKit', '~> 5.0.1'
  end

  s.subspec 'YXUtils' do |ss|
      ss.source_files = 'YXKit/Classes/YXUtils'
      ss.dependency 'YXKit/HLNetWorkReachability'
      ss.dependency 'YXKit/Core'
      ss.dependency 'MMKV'
      ss.dependency 'SwiftyJSON', '~> 5.0.0'
      ss.dependency 'SAMKeychain'
      ss.dependency 'YYCategories'
  end

  s.subspec 'YXSecret' do |ss|
      ss.source_files = 'YXKit/Classes/YXSecret/*.{h,m}', 'YXKit/Classes/YXSecret/dotmot/*.{c,h}'
      ss.public_header_files = 'YXKit/Classes/YXSecret/*.h'
      ss.dependency 'YXKit/Core'
  end

  s.subspec 'HLNetWorkReachability' do |ss|
      ss.source_files = 'YXKit/Classes/Reachability'
      ss.dependency 'YXKit/Core'
  end
  
  s.subspec 'YXTabView' do |ss|
    ss.source_files = 'YXKit/Classes/YXTabView'
    ss.dependency 'YXKit/Core'    
    ss.dependency 'Masonry'
  end
  
  s.subspec 'YXTimerSingleton' do |ss|
    ss.source_files = 'YXKit/Classes/YXTimerSingleton'
    ss.dependency 'YXKit/Core'
  end
  
  s.subspec 'YXSocketSingleton' do |ss|
    ss.source_files = 'YXKit/Classes/YXSocketSingleton', 'YXKit/Classes/YXSocketSingleton/proto/*.{h,m}', 'YXKit/Classes/YXSocketSingleton/ServerNode/*.swift'
    ss.requires_arc = false
    ss.requires_arc = ['YXKit/Classes/YXSocketSingleton/*.m']
    
    ss.dependency 'YXKit/YXMoyaRequest'
    ss.dependency 'YXKit/YXUtils'
    ss.dependency 'YXKit/YXTimerSingleton'
    ss.dependency 'YXKit/YXConstant'
    ss.dependency 'YXKit/Core'
    ss.dependency 'Protobuf'
    ss.dependency 'CocoaAsyncSocket'
    ss.dependency 'MMKV'
    
    ss.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
  end

  #s.subspec 'YXSecuGroupManager' do |ss|
    #ss.source_files = 'YXKit/Classes/YXSecuGroupManager'
    #ss.dependency 'YXKit/YXTimerSingleton'
    #ss.dependency 'YXKit/YXUtils'
    
    #ss.dependency 'YYModel'
    #ss.dependency 'MMKV'
    #end
  
  #s.subspec 'YXOptionalDBManager' do |ss|
  #ss.source_files = 'YXKit/Classes/YXOptionalDBManager'
  #ss.dependency 'YXKit/YXSecuGroupManager'
  #    ss.dependency 'YXKit/YXSocketSingleton'
      
      #    ss.dependency 'WCDB'
      #ss.libraries = 'z', 'c++'
      #end

  s.subspec 'YXLogUtil' do |ss|
      ss.source_files = 'YXKit/Classes/YXLogUtil'
      ss.dependency 'YXKit/YXConstant'
      ss.dependency 'YXKit/Core'
      ss.vendored_frameworks = 'YXKit/Classes/YXLogUtil/mars.framework'
      
      ss.libraries = 'z', 'c++'
      
      ss.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }
      ss.xcconfig = {'BITCODE_GENERATION_MODE' => '-fembed-bitcode'}
  end
  
  s.subspec 'YXMoyaRequest' do |ss|
      ss.source_files = 'YXKit/Classes/YXMoyaRequest', 'YXKit/Classes/YXMoyaRequest/YXRealLogger/*.swift', 'YXKit/Classes/YXMoyaRequest/YXGlobalConfig/*.swift',
          'YXKit/Classes/YXMoyaRequest/YXRetryConfig/*.swift', "YXKit/Classes/YXMoyaRequest/YXDNSResolver/*.{h,m}"
      ss.public_header_files = 'YXKit/Classes/YXMoyaRequest/YXDNSResolver/*.h'
      ss.dependency 'YXKit/YXLogUtil'
      ss.dependency 'YXKit/YXUtils'
      ss.dependency 'YXKit/YXConstant'
      ss.dependency 'YXKit/Core'
      ss.dependency 'Moya/RxSwift', '~> 14.0'
      ss.dependency 'Alamofire', '5.4.3'
      ss.dependency 'SSZipArchive'
      ss.dependency 'MMKV'
      ss.dependency 'NSObject+Rx'
      ss.dependency 'MSDKDns_C11', '1.3.3'
  end
  
  s.subspec 'YXQuoteManager' do |ss|
    ss.source_files = 'YXKit/Classes/YXQuoteManager'
    ss.dependency 'YXKit/Core'
    ss.dependency 'YXKit/YXMoyaRequest'
    ss.dependency 'YXKit/YXSocketSingleton'
    ss.dependency 'YXKit/YXTimerSingleton'
  end

  s.subspec 'YXNativeRouter' do |ss|
      ss.source_files = 'YXKit/Classes/YXNativeRouter'
      ss.dependency 'YXKit/Core'
  end

  s.subspec 'YXWKWebView' do |ss|
      ss.source_files = 'YXKit/Classes/YXWKWebView', 'YXKit/Classes/YXWKWebView/JSBridge'

      ss.dependency 'YXKit/YXNativeRouter'
      ss.dependency 'YXKit/YXLogUtil'
      ss.dependency 'YXKit/Core'
  end
  
  s.subspec 'NFCPassportReader' do |ss|
      ss.source_files = 'YXKit/Classes/NFCPassportReader'
      
      ss.dependency 'CryptoSwift', '1.4.2'
      ss.dependency 'YXKit/Core'
  end
  
end
