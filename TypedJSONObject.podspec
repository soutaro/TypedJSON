Pod::Spec.new do |spec|
  spec.name         = 'TypedJSONObject'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/soutaro/TypedJSONobject'
  spec.authors      = { 'Soutaro Matsumoto' => 'soutaro@ubiregi.com' }
  spec.summary      = 'Given JSON Object a Type'
  spec.source       = { :git => 'https://github.com/soutaro/TypedJSONObject.git', :tag => spec.version.to_s }
  spec.source_files = 'TypedJSONObject/*.swift'
  spec.platform     = :ios, "8.0"
  spec.requires_arc = true
end
