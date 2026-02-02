
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint abdalsalam_logic_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'abdalsalam_logic_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A comprehensive Flutter logic package providing reusable modules.'
  s.description      = <<-DESC
A comprehensive Flutter logic package providing reusable modules for app state, networking, storage, auth, and more.
                       DESC
  s.homepage         = 'https://github.com/yourusername/abdalsalam_logic_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Organization' => 'your.email@example.com' }
  
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end