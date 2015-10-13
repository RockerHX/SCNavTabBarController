
Pod::Spec.new do |s|
  s.name         = "SCNavTabBarController"
  s.version      = "0.0.1"
  s.summary      = "SCNavTabBarController demo is like news client control and manager subviewcontroller"
  s.description  = <<-DESC
                   Fork from original master branch, and my reversion added features autolayout support
                   can specify container view, more property to modify apperance.
                   DESC

  s.homepage     = "https://github.com/gevin/SCNavTabBarController"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => 'BSD' }
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "GevinChen" => "lowgoo@gmail.com" }
  # Or just: s.author    = "GevinChen"
  # s.authors            = { "GevinChen" => "lowgoo@gmail.com" }
  # s.social_media_url   = "http://twitter.com/GevinChen"
  s.platform     = :ios, '8.0'
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  s.source       = { :git => "https://github.com/gevin/SCNavTabBarController.git" }
  s.source_files  = "SCNavTabBarController/**"
  
  # s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"
  
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  
  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  
  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
