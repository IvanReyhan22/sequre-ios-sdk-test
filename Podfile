# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name.include?('iphonesimulator')
        config.build_settings['EXCLUDED_ARCHS'] = 'arm64'
      end
    end
  end
end

target 'SequreSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for SequreSDK
  pod 'TensorFlowLiteTaskVision'
  pod 'TensorFlowLiteSwift'
  pod 'Alamofire', '~> 5.5'

  target 'SequreSDKTests' do
    # Pods for testing
  end

end
