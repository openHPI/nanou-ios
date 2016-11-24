use_frameworks!
platform :ios, '10.0'

target 'nanou-ios' do
  pod 'Alamofire', '4.2.0'
  pod 'CocoaLumberjack/Swift', '3.0.0'
  pod 'LNRSimpleNotifications', '0.5.3'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
