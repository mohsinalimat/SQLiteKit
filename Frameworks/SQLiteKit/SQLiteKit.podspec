Pod::Spec.new do |s|
  s.name         = 'SQLiteKit'
  s.version      = '0.0.5'
  s.license = 'MIT'
  s.requires_arc = true
  s.source = { :git => 'https://github.com/alexiscn/SQLiteKit.git', :tag => s.version.to_s }

  s.summary = 'SQLiteKit based on FMDB and Swift Codable'
  s.homepage = 'https://github.com/alexiscn/SQLiteKit'
  s.license          = { :type => 'MIT' }
  s.author       = { 'xushuifeng' => 'shuifengxu@gmail.com' }
  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'
  s.source_files = '*.{h,m,swift}', '**/*.{h,m,swift}'
  s.private_header_files = '**/FMDB/*.h'
  s.public_header_files = '**/FMDB/FMDB.h'

end
