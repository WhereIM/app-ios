# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'whereim' do
  use_frameworks!

  pod 'Alamofire', '~> 4.3'

  pod 'Branch'

  pod 'FacebookCore'
  pod 'FacebookLogin'

  pod 'Firebase/Core'
  pod 'Firebase/Crash'

  pod 'GRDB.swift'

  pod 'JSQMessagesViewController'

  pod 'Mapbox-iOS-SDK', '~> 3.5.2'

  pod 'Moscapsule', :git => 'https://github.com/flightonary/Moscapsule.git'
  pod 'OpenSSL-Universal', '~> 1.0.1.18'

  pod 'GoogleMaps'
  pod 'Google/SignIn'

  pod 'SDCAlertView', '~> 7.1'

  pod 'Toast-Swift', '~> 2.0.0'

  target 'whereimTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'whereimUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
