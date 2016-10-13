#
# Be sure to run `pod lib lint BMCommons.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BMCommons'
  s.version          = '1.0.0'
  s.summary          = 'BehindMedia Commons Library'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/werner77/BMCommons'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Werner Altewischer' => 'werner.altewischer@gmail.com' }
  s.source           = { :git => 'https://github.com/werner77/BMCommons.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '6.0'
  s.platform = :ios

  s.subspec 'BMCore' do |s_core|
    s_core.frameworks   = 'Foundation','UIKit','CoreGraphics','SystemConfiguration','AudioToolbox','Security'
    s_core.prefix_header_file = 'BMCommons/BMCore/Sources/Other/BMCore_Prefix.pch'
    s_core.header_dir = 'BMCore'
    s_core.libraries = 'z', 'icucore', 'xml2'
    s_core.subspec 'arc' do |s_core_arc|
      s_core_arc.requires_arc = true
      s_core_arc.compiler_flags = '-Wno-arc-performSelector-leaks'
      s_core_arc.source_files = 'BMCommons/BMCore/Sources/**/*.{c,m,h}'
      s_core_arc.exclude_files = 'BMCommons/BMCore/**/*_Private.*','BMCommons/BMCore/Sources/Classes/BMRegexKitLite.m','BMCommons/BMCore/Sources/Classes/BMKeychainItemWrapper.m','BMCommons/BMCore/Sources/Classes/NSString+BMCommons_noarc.m'
    end
    s_core.subspec 'no-arc' do |s_core_noarc|
      s_core_noarc.requires_arc = false
      s_core_noarc.source_files = 'BMCommons/BMCore/Sources/Classes/BMRegexKitLite.m','BMCommons/BMCore/Sources/Classes/BMKeychainItemWrapper.m','BMCommons/BMCore/Sources/Classes/NSString+BMCommons_noarc.m'
    end
  end

  s.subspec 'BMUICore' do |s_uicore|
    s_uicore.frameworks   = 'CoreData'
    s_uicore.prefix_header_file = 'BMCommons/BMUICore/Sources/Other/BMUICore_Prefix.pch'
    s_uicore.header_dir = 'BMUICore'
    s_uicore.requires_arc = true
    s_uicore.compiler_flags = '-Wno-arc-performSelector-leaks'
    s_uicore.source_files = 'BMCommons/BMUICore/Sources/**/*.{c,m,h}'
    s_uicore.exclude_files = 'BMCommons/BMUICore/**/*_Private.*'
    s_uicore.resource_bundle = { 'BMUICore' => 'BMCommons/BMUICore/Resources/**/*.*' }
  end

  s.subspec 'BMUIExtensions' do |s_uiext|
    s_uiext.prefix_header_file = 'BMCommons/BMUIExtensions/Sources/Other/BMUIExtensions-Prefix.pch'
    s_uiext.header_dir = 'BMUIExtensions'
    s_uiext.requires_arc = true
    s_uiext.compiler_flags = '-Wno-arc-performSelector-leaks'
    s_uiext.source_files = 'BMCommons/BMUIExtensions/Sources/**/*.{c,m,h}'
    s_uiext.exclude_files = 'BMCommons/BMUIExtensions/**/*_Private.*'
    s_uiext.dependency 'BMCommons/BMUICore'
  end

  s.subspec 'BMCoreData' do |s_coredata|
    s_coredata.frameworks   = 'CoreMedia','AVFoundation','QuartzCore'
    s_coredata.prefix_header_file = 'BMCommons/BMCoreData/Sources/Other/BMCoreData-Prefix.pch'
    s_coredata.header_dir = 'BMCoreData'
    s_coredata.requires_arc = true
    s_coredata.compiler_flags = '-Wno-arc-performSelector-leaks'
    s_coredata.source_files = 'BMCommons/BMCoreData/Sources/**/*.{c,m,h}'
    s_coredata.exclude_files = 'BMCommons/BMCoreData/**/*_Private.*'
    s_coredata.dependency 'BMCommons/BMCore'
  end  

  s.subspec 'BMXML' do |s_xml|
    s_xml.prefix_header_file = 'BMCommons/BMXML/Sources/Other/BMXML-Prefix.pch'
    s_xml.header_dir = 'BMXML'
    s_xml.requires_arc = true
    s_xml.compiler_flags = '-Wno-arc-performSelector-leaks'
    s_xml.source_files = 'BMCommons/BMXML/Sources/**/*.{c,m,h}'
    s_xml.exclude_files = 'BMCommons/BMXML/**/*_Private.*'
    s_xml.xcconfig     = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  end

  s.subspec 'BMRestKit' do |s_restkit|
    s_restkit.frameworks   = 'CoreData'
    s_restkit.prefix_header_file = 'BMCommons/BMRestKit/Sources/Other/BMRestKit-Prefix.pch'
    s_restkit.header_dir = 'BMCommons/BMRestKit'
    s_restkit.requires_arc = true
    s_restkit.compiler_flags = '-Wno-arc-performSelector-leaks'
    s_restkit.source_files = 'BMCommons/BMRestKit/Sources/**/*.{c,m,h}'
    s_restkit.exclude_files = 'BMCommons/BMRestKit/**/*_Private.*'
    s_restkit.dependency 'BMCommons/BMCore'
    s_restkit.dependency 'yajl-objc'
  end

end
