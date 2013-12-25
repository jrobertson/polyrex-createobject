Gem::Specification.new do |s|
  s.name = 'polyrex-createobject'
  s.version = '0.4.14'
  s.summary = 'polyrex-createobject'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('polyrex-schema') 
  s.signing_key = '../privatekeys/polyrex-createobject.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/polyrex-createobject'
end
