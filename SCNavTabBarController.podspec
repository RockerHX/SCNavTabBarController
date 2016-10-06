
Pod::Spec.new do |s|
  s.name         = "SCNavTabBarController"
  s.version      = "0.1.1"
  s.summary      = "SCNavTabBarController demo is like news client control and manager subviewcontroller"
  s.description  = <<-DESC
                   Fork from original master branch, and my reversion added features autolayout support
                   can specify container view, more property to modify apperance.
                   DESC

  s.homepage     = "https://github.com/DonYang/SCNavTabBarController"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "shicang1990" => "shicang1990@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/DonYang/SCNavTabBarController.git", :tag=>s.version.to_s}
  s.requires_arc = true
  s.source_files  = 'SCNavTabBarController/**/*.{h,m}'
  s.resources = "SCNavTabBarController/*.bundle"
  s.framework  = "Foundation", "UIKit"

end
