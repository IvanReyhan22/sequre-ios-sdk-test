Pod::Spec.new do |spec|

  spec.name         = "SequreSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Sequre Scanner SDK framework."
  spec.description  = "Sequre Scanner SDK framework for Sequre app to detect qr code"

  spec.homepage     = "https://github.com/IvanReyhan22/sequre-ios-sdk-test"
  spec.license      = ""
  spec.author       = { "Ahmad Ivan Reyhan" => "ivanreyhan2002@gmail.com" }
  spec.platform     = :ios
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://github.com/IvanReyhan22/sequre-ios-sdk-test.git", :tag => spec.version.to_s }

  spec.source_files  = "SequreSDK/**/*.{swift}", "Classes/**/*.{h,m}"

  spec.resource_bundles = {
    "SequreSDK" => ['SequreSDK/Assets.xcassets']
  }

  # spec.static_framework = true
  spec.dependency 'TensorFlowLiteTaskVision'
  spec.dependency 'TensorFlowLiteSwift'
  spec.dependency 'Alamofire', '~> 5.5'

  # spec.pod_target_xcconfig = {
  #   'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  # }
  spec.requires_arc = true
  spec.static_framework = false

  spec.swift_versions = "5.0"

end
