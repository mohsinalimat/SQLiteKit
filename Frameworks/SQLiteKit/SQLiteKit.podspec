Pod::Spec.new do |s|
  s.name         = 'SQLiteKit'
  s.version      = '0.0.1'
  s.license = 'MIT'
  s.requires_arc = true
  s.source = { :path => 'DevelopmentPods/SQLiteKit' }

  s.summary = 'SQLiteKit for PhotoX'
  s.homepage = 'No homepage'
  s.author       = { 'xushuifeng' => 'shuifengxu@gmail.com' }
  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  s.source_files = '*.{h,m,swift}', '**/*.{h,m,swift}'

  s.dependency 'FMDB'
  
end
