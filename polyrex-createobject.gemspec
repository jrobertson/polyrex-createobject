Gem::Specification.new do |s|
  s.name = 'polyrex-createobject'
  s.version = '0.8.0'
  s.summary = 'polyrex-createobject'
  s.authors = ['James Robertson']
  s.files = Dir['lib/polyrex-createobject.rb']
  s.add_runtime_dependency('polyrex-schema', '~> 0.5', '>=0.5.1') 
  s.signing_key = '../privatekeys/polyrex-createobject.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/polyrex-createobject'
  s.required_ruby_version = '>= 2.1.0'
end
