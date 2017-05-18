# coding: utf-8
Pod::Spec.new do |s|
  s.name         = "QHCoreLib"
  s.version      = "0.0.1"
  s.summary      = "QHCoreLib inlucdes some macros and util classes."
  s.homepage     = "http://git.code.oa.com/QHLib/QHCoreLib.git"
  s.license      = "MIT"
  s.author       = { "changtang(唐畅)" => "changtang@tencent.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "http://git.code.oa.com/QHLib/QHCoreLib.git", :tag => s.version }

  s.source_files  = "QHCoreLib/QHCoreLib.h"
  s.public_header_files = "QHCoreLib/QHCoreLib.h"
  s.prefix_header_contents = <<-EOS
                             EOS

  s.requires_arc = true

  s.subspec 'QHDefines' do |ss|
    ss.source_files = "Classes/Defines/**/*.{h,m}"
    ss.framework = "Foundation"
    ss.dependency "libextobjc", '0.4.1'
    ss.dependency 'MustOverride', '1.1'
  end

  s.subspec 'QHLog' do |ss|
    ss.source_files = "Classes/Log/**/*.{h,m}"
    ss.framework = "Foundation"
  end

  s.default_subspecs = 'QHDefines', 'QHLog'

end
