Gem::Specification.new do |s|
  s.name        = 'toygit'
  s.version     = `git describe`[1..-1]
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'ToyGit'
  s.description = 'Toy Git'
  s.authors     = ['GYUMIN SIM']
  s.email       = 'sim0629@gmail.com'
  s.files       = ['bin/toygit', 'lib/toygit.rb']
  s.files       += Dir.glob('lib/toygit/*.rb')
  s.bindir      = 'bin'
  s.executables = ['toygit']
  s.homepage    = 'https://github.com/sim0629/toygit'
  s.license     = 'MIT'

  # Dependencies
  s.add_runtime_dependency 'rugged', '0.19.0'
end
