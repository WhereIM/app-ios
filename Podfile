# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'whereim' do
  use_frameworks!

  pod 'Alamofire'

  pod 'Branch'

  pod 'FacebookCore'
  pod 'FacebookLogin'

  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Crash'

  pod 'GRDB.swift'

  pod 'JSQMessagesViewController'

  pod 'Mapbox-iOS-SDK'

  pod 'Moscapsule', :git => 'https://github.com/flightonary/Moscapsule.git'
  pod 'OpenSSL-Universal'

  pod 'GoogleMaps'
  pod 'GoogleSignIn'

  pod 'SDCAlertView'

  pod 'Toast-Swift'

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
