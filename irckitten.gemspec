$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = 'irckitten'
  s.version = '0.0.2'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Ben Hughes']
  s.email = ['ben@mumble.org.uk']
  s.homepage = 'https://github.com/barn/irckitten'
  s.summary = 'Module to talk simple IRCCat based on SRV DNS records'
  s.description = 'Send message to IRC via IRCCat, but without having
  to manually configure a server in your code. Just use DNS as RFC822
  intended.'

  s.files = [
    '.gitignore',
    'README.md',
  ] + Dir['{bin,lib}/**/*']

  s.executables = ['irckitten']

  # No dependancies, but there might be in future.
  #s.add_dependency "thor", "~> 0.15"
  # s.add_development_dependency "rake"
end
