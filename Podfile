# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target 'SequreSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SequreSDK
  pod 'TensorFlowLiteTaskVision'

  target 'SequreSDKTests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'].nil?
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end

  end
end
