
Pod::Spec.new do |s|
  s.name         = "SCNavTabBarController"
  s.version      = "0.1.0"
  s.summary      = "SCNavTabBarController demo is like news client control and manager subviewcontroller"
  s.description  = <<-DESC
                   Fork from original master branch, and my reversion added features autolayout support
                   can specify container view, more property to modify apperance.
                   DESC

  s.homepage     = "https://github.com/DonYang/SCNavTabBarController"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "shicang1990" => "shicang1990@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/DonYang/SCNavTabBarController.git" }
  s.source_files  = 'SCNavTabBarController/**/*.{h,m}'
  s.resources = "SCNavTabBarController/*.bundle"
  s.framework  = "Foundation", "UIKit"
  s.requires_arc = true

end
