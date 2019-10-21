#
# Be sure to run `pod lib lint GeoHex3.swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GeoHex3.swift'
  s.version          = '0.2.0'
  s.summary          = 'GeoHex3 library for Swift'

  s.homepage         = 'https://github.com/nekowen/GeoHex3.swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nekowen' => 'nekonyanowen@gmail.com' }
  s.source           = { :git => 'https://github.com/nekowen/GeoHex3.swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'GeoHex3.swift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GeoHex3.swift' => ['GeoHex3.swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreLocation'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.requires_arc = true
  s.module_name = 'GeoHex3Swift'
end
