Pod::Spec.new do |s|

  s.name         = "AXBadgeView-Swift"
  s.version      = "1.0.0"
  s.summary      = "AXBadgeView-Swift is a tool to add badge view to your projects."
  s.description  = <<-DESC
                      AXBadgeView-Swift is a tool to add badge view to your projects on ios platform using swift.
                      DESC
  s.homepage     = "https://github.com/devedbox/AXAutoreversePlayCollectionView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "devedbox" => "devedbox@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/devedbox/AXAutoreversePlayCollectionView.git", :tag => "1.0.0" }
  s.source_files  = "AXAutoreversePlayCollectionView/AXAutoreversePlayCollectionView/*.{h,m}"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true
  s.dependency "AXCollectionViewFlowLayout"
  s.dependency "AXExtensions"

end
