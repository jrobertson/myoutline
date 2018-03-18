Gem::Specification.new do |s|
  s.name = 'myoutline'
  s.version = '0.1.2'
  s.summary = 'Helps build an outline from plain text.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/myoutline.rb']
  s.add_runtime_dependency('pxindex', '~> 0.1', '>=0.1.6')
  s.signing_key = '../privatekeys/myoutline.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/myoutline'
end
