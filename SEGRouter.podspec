#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "SEGRouter"
  s.version      = "0.1.0"
  s.summary      = "Easy in-app URL routing"
  s.homepage     = "https://github.com/segiddins/SEGRouter"
  s.license      = 'BSD'
  s.author       = { "Samuel E. Giddins" => "segiddins@segiddins.me" }
  s.source       = { :git => "https://github.com/segiddins/SEGRouter", :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'RKSupport/RKPathTemplate', '~> 1.0'
end

