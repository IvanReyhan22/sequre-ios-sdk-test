Pod::Spec.new do |spec|

  spec.name         = "SequreSDK"
  spec.version      = "1.1.0"
  spec.summary      = "Sequre Scanner SDK framework."
  spec.description  = "Sequre Scanner SDK framework for Sequre app to detect qr code"

  spec.homepage     = "https://github.com/IvanReyhan22/sequre-ios-sdk-test"
  spec.license      = ""
  spec.author       = { "Ahmad Ivan Reyhan" => "ivanreyhan2002@gmail.com" }
  spec.platform     = :ios, "15.0"
  # spec.source       = { :git => "https://github.com/IvanReyhan22/sequre-ios-sdk-test.git", :tag => spec.version.to_s } 
  spec.source = { :path => "." }

  spec.source_files  = "SequreSDK/**/*.{swift}", "Classes/**/*.{h,m}", "SequreSDK/**/*.{colorset}"
  spec.resources = ['SequreSDK/**/*.tflite', 'SequreSDK/**/*.xcassets']

  spec.dependency 'TensorFlowLiteTaskVision'
  spec.dependency 'TensorFlowLiteSwift'
  spec.dependency 'Alamofire', '~> 5.5'
  # spec.pod_target_xcconfig = {
  #   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  #   'VALID_ARCHS' => 'x86_64 armv7 armv7s arm64e i386'
  # }

  # spec.user_target_xcconfig = {
  #   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  #   'VALID_ARCHS' => 'x86_64 armv7 armv7s arm64e i386'
  # }

  spec.static_framework = true

  spec.swift_versions = "5.0"

end
