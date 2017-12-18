Pod::Spec.new do |s|

  s.name         = "ServicesManager"
  s.version      = "1.0.0"
  s.summary      = "Megaleios request class."
  s.description  = "ServicesManager classe de request megaleios."

  s.homepage     = "http://megaleios.com/"

  s.license      = "MIT"

  s.author             = { "Leo Valentim" => "leo@megaleios.com" }
  s.platform     = :ios, "10.3"

  s.source       = { :path => '.' }
  #s.source       = { :git => "https://github.com/LeoValentim/ServicesManager.git", :tag => "1.0.0" }

  s.source_files = "ServicesManager", "ServicesManager/**/*.{h,m,swift}"


  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

  s.ios.dependency 'JWTDecode', '~> 2.1'
  s.ios.dependency 'Alamofire', '~> 4.5'

end
