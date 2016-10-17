platform :ios, '8.0'
use_frameworks!

def swift3_overrides
  pod 'Kanna', git: 'https://github.com/tid-kijyun/Kanna.git', branch: 'swift3.0'
  pod 'URLEmbeddedView', :git => 'https://github.com/marty-suzuki/URLEmbeddedView.git', :tag => '0.6.0'
end

target 'DUMessenger' do
  swift3_overrides
  pod 'DUMessagingUIKit', :git => 'https://github.com/Diuit/DUMessagingUIKit-iOS', :tag => '0.2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
