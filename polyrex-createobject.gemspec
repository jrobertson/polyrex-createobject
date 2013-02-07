Gem::Specification.new do |s|
  s.name = 'polyrex-createobject'
  s.version = '0.4.12'
  s.summary = 'polyrex-createobject'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('polyrex-schema') 
  s.signing_key = '../privatekeys/polyrex-createobject.pem'
  s.cert_chain  = ['gem-public_cert.pem']
end
