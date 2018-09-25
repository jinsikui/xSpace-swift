# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'xSpace-swift' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftyJSON'
  pod 'SnapKit', '~> 3.0.0'
  pod 'SwinjectStoryboard'
  pod 'RxAlamofire'
  pod 'YYText'
  pod 'AlamofireImage'
  pod 'PKHUD'
  pod 'KVOController'
  pod 'MJRefresh'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
