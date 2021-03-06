Gem::Specification.new do |s|
  s.name = 'myoutline'
  s.version = '0.5.1'
  s.summary = 'Helps build an outline from plain text.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/myoutline.rb']
  s.add_runtime_dependency('pxindex', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('nokogiri', '~> 1.8', '>=1.8.2')
  s.add_runtime_dependency('filetree_xml', '~> 0.1', '>=0.1.3')
  s.add_runtime_dependency('polyrex-links', '~> 0.3', '>=0.3.0')
  s.add_runtime_dependency('md_edit', '~> 0.2', '>=0.2.5')
  s.signing_key = '../privatekeys/myoutline.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/myoutline'
end
