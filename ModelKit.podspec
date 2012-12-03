Pod::Spec.new do |s|
  s.name         =  'ModelKit'
  s.version      =  '0.0.1'
  s.license      =  'Copyright (c) 2012 Interfacelab LLC. All rights reserved.'
  s.summary      =  'ModelKit is a simple to use model framework for Objective-C (Cocoa/iOS).'
  s.description  =  'ModelKit is a simple to use model framework for Objective-C (Cocoa/iOS). It allows you to write your model layer quickly and easily, managing persistence (local and network) for you.'
  s.homepage     =  'http://jawngee.github.com/ModelKit'
  s.author       =  { 'Jon Gilkison' => '' }
  s.source       =  { :git => 'https://github.com/jawngee/ModelKit.git', :commit => 'd598e01c06'}
  s.source_files =  'Source/**/*.{h,m}'
  s.header_dir   =  'Source/**'
  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'MobileCoreServices', 'CoreGraphics', 'CoreLocation', 'MobileCoreServices', 'Security', 'SystemConfiguration', 'Foundation'
  s.osx.deployment_target = '10.7'
  s.osx.frameworks = 'CoreServices', 'CoreGraphics', 'CoreLocation', 'MobileCoreServices', 'Security', 'SystemConfiguration', 'Foundation'
  s.dependency      'AFNetworking'
  s.dependency      'JSONKit'
  s.dependency      'ISO8601DateFormatter'
end