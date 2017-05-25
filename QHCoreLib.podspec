# coding: utf-8
Pod::Spec.new do |s|
  s.name         = "QHCoreLib"
  s.version      = "0.0.4"
  s.summary      = "QHCoreLib inlucdes some macros and util classes."
  s.homepage     = "http://git.code.oa.com/QHLib/QHCoreLib.git"
  s.license      = "MIT"
  s.author       = { "changtang(唐畅)" => "changtang@tencent.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "http://git.code.oa.com/QHLib/QHCoreLib.git", :tag => s.version }

  s.requires_arc = true

  s.source_files  = "QHCoreLib/QHCoreLib.{h,m}"
  s.public_header_files = "QHCoreLib/QHCoreLib.h"
  s.prefix_header_contents = <<-EOS
                             EOS

  s.subspec 'QHBase' do |ss|
    ss.source_files = "Classes/Base/**/*.{h,m}"
    ss.frameworks = "Foundation", "QuartzCore"
    ss.dependency "libextobjc", '0.4.1'
    ss.dependency 'MustOverride', '1.1'
  end

  s.subspec 'QHLog' do |ss|
    ss.source_files = "Classes/Log/**/*.{h,m}"
    ss.frameworks = "Foundation"
    ss.dependency "QHCoreLib/QHBase"
  end

  s.subspec 'QHNetwork' do |ss|
    ss.source_files = "Classes/Network/**/*.{h,m}"
    ss.frameworks = "Foundation", "CoreTelephony", "MobileCoreServices", "SystemConfiguration", "CoreGraphics"
    ss.dependency "QHCoreLib/QHBase"
    ss.dependency "QHCoreLib/QHLog"
  end

  s.default_subspecs = 'QHBase', 'QHLog', 'QHNetwork'
end
