Pod::Spec.new do |spec|
  spec.name         = "DatacapTokenLibrary"
  spec.version      = "1.0.0"
  spec.summary      = "iOS library for Datacap payment tokenization"
  spec.description  = <<-DESC
    DatacapTokenLibrary provides an easy-to-use interface for tokenizing payment cards
    using Datacap's tokenization API. Features include built-in UI, card validation,
    and support for both certification and production environments.
  DESC

  spec.homepage     = "https://github.com/datacapsystems/DatacapTokenLibrary-iOS"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Datacap Systems" => "support@datacapsystems.com" }
  
  spec.platform     = :ios, "13.0"
  spec.swift_version = "5.0"
  
  spec.source       = { 
    :git => "https://github.com/datacapsystems/DatacapTokenLibrary-iOS.git", 
    :tag => "#{spec.version}" 
  }
  
  spec.source_files = "Sources/DatacapTokenLibrary/**/*.swift"
  
  spec.frameworks   = "UIKit", "Foundation"
  spec.requires_arc = true
end