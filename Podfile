use_frameworks!
platform :ios, '10.0'

plugin 'cocoapods-acknowledgements', :settings_bundle => true

target 'nanou-ios' do
  pod 'Alamofire', '4.2.0'
  pod 'BrightFutures', '5.1.0'
  pod 'Cosmos', '~> 8.0'
  pod 'Firebase/Core', '~> 3.11'
  pod 'TagListView', '~> 1.1'
  pod 'LNRSimpleNotifications', '0.5.3'
  pod 'Onboard', '~> 2.3'
  pod 'ProcedureKit', '4.0.0'
  pod 'ProcedureKit/Network', '4.0.0'
  pod 'ProcedureKit/Mobile', '4.0.0'
  pod 'SDWebImage/WebP', '~> 4.0'
  pod 'SIFloatingCollection', :git => 'https://github.com/pavan309/SIFloatingCollection_Swift', :commit => 'e22f687'
  pod 'Spine', :git => 'https://github.com/wvteijlingen/Spine.git', :commit => 'a87ea59'
  pod 'SwiftyBeaver', '1.1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
