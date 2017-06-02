# coding: utf-8
Pod::Spec.new do |s|
  s.name         = "QHCoreLib"
  s.version      = "0.0.5"
  s.summary      = "QHCoreLib inlucdes some macros and util classes."
  s.homepage     = "https://github.com/QHLib/QHCoreLib.git"
  s.license      = "MIT"
  s.author       = { "changtang(唐畅)" => "changtang@tencent.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/QHLib/QHCoreLib.git", :tag => s.version }

  s.requires_arc = true

  s.source_files  = "QHCoreLib/QHCoreLib*.h"
  s.public_header_files = "QHCoreLib/QHCoreLib*.h"
  s.prefix_header_contents = <<-EOS
                             EOS
  #s.module_map = "QHCoreLib/QHCoreLib.modulemap"

  s.subspec 'QHBase' do |ss|
    ss.source_files = "QHCoreLib/Base/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Base/**/*.h"
    ss.frameworks = "Foundation"
    ss.dependency "libextobjc", '0.4.1'
    ss.dependency 'MustOverride', '1.1'
  end

  s.subspec 'QHLog' do |ss|
    ss.source_files = "QHCoreLib/Log/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Log/QHLogUtil.h", "QHCoreLib/Log/Lumberjack/DDLog.h"
    ss.frameworks = "Foundation"
    ss.dependency "QHCoreLib/QHBase"
  end

  s.subspec 'QHProfiler' do |ss|
    ss.source_files = "QHCoreLib/Profiler/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Profiler/**/*.h"
    ss.frameworks = "Foundation", "QuartzCore"
    ss.dependency "QHCoreLib/QHBase"
  end

  s.subspec 'QHNetwork' do |ss|
    ss.source_files = "QHCoreLib/Network/**/*.{h,m}"
    ss.public_header_files = "QHCoreLib/Network/**/*.h"
    ss.private_header_files = "QHCoreLib/Network/Worker-internal/**/*.h"
    ss.frameworks = "Foundation", "CoreTelephony", "MobileCoreServices", "SystemConfiguration", "CoreGraphics"
    ss.dependency "QHCoreLib/QHBase"
    ss.dependency "QHCoreLib/QHLog"
    ss.dependency "QHCoreLib/QHProfiler"
  end

end
