Pod::Spec.new do |s|

  s.name         = "AXAutoreversePlayCollectionView"
  s.version      = "1.2.0"
  s.summary      = "AXAutoreversePlayCollectionView a auto reverse play view."
  s.description  = <<-DESC
                      AXAutoreversePlayCollectionView a auto reverse play view using for advertisement.
                      DESC
  s.homepage     = "https://github.com/devedbox/AXAutoreversePlayCollectionView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "devedbox" => "devedbox@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/devedbox/AXAutoreversePlayCollectionView.git", :tag => "1.2.0" }
  s.source_files  = "AXAutoreversePlayCollectionView/AXAutoreversePlayCollectionView/*.{h,m}"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true
  s.dependency "AXPreviewingCollectionViewFlowLayout"
  s.dependency "AXExtensions"

end
