# coding: utf-8
Pod::Spec.new do |s|
  s.name         = "QHCoreLib"
  s.version      = "0.0.23"
  s.summary      = "QHCoreLib inlucdes some macros and util classes."
  s.homepage     = "http://git.code.oa.com/QHLib/QHCoreLib.git"
  s.license      = "MIT"
  s.author       = { "changtang(唐畅)" => "changtang@tencent.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "http://git.code.oa.com/QHLib/QHCoreLib.git", :tag => s.version }

  s.requires_arc = true

  s.source_files  = "QHCoreLib/QHCoreLib.h", "QHCoreLib/QHCoreLib+All.h"
  s.public_header_files = "QHCoreLib/QHCoreLib.h", "QHCoreLib/QHCoreLib+All.h"
  s.prefix_header_contents = <<-EOS
                             EOS
  s.xcconfig = {
    "OTHER_LDFLAGS" => "-ObjC",
  }

  s.subspec 'QHBase' do |ss|
    ss.source_files = "QHCoreLib/Base/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Base/**/*.h"
    ss.private_header_files = "QHCoreLib/Base/Internal/**/*.h"
    ss.frameworks = "Foundation", "Security", "MobileCoreServices", "CoreGraphics"
    ss.dependency "libextobjc", '0.4.1'
  end

  s.subspec 'QHLog' do |ss|
    ss.source_files = "QHCoreLib/Log/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Log/**/*.h"
    ss.private_header_files = "QHCoreLib/Log/Lumberjack/**/*.h"
    ss.frameworks = "Foundation"
    ss.dependency "QHCoreLib/QHBase"
  end

  s.subspec 'QHProfiler' do |ss|
    ss.source_files = "QHCoreLib/Profiler/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Profiler/**/*.h"
    ss.frameworks = "Foundation", "QuartzCore"
    ss.dependency "QHCoreLib/QHBase"
  end

  s.subspec 'QHAsync' do |ss|
    ss.source_files = "QHCoreLib/Async/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Async/**/*.h"
    ss.frameworks = "Foundation"
    ss.dependency "QHCoreLib/QHBase"
    ss.dependency "QHCoreLib/QHLog"
    ss.dependency "QHCoreLib/QHProfiler"
  end

  s.subspec 'QHNetwork' do |ss|
    ss.source_files = "QHCoreLib/Network/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Network/**/*.h"
    ss.private_header_files = "QHCoreLib/Network/Worker-internal/**/*.h"
    ss.frameworks = "Foundation", "CoreTelephony", "MobileCoreServices", "SystemConfiguration", "CoreGraphics"
    ss.dependency "QHCoreLib/QHBase"
    ss.dependency "QHCoreLib/QHLog"
    ss.dependency "QHCoreLib/QHProfiler"
    ss.dependency "QHCoreLib/QHAsync"
  end

end
