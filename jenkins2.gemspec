# -*- encoding: utf-8 -*-
require_relative 'lib/jenkins2/version'

Gem::Specification.new do |s|
	s.name = 'jenkins2'
	s.version = Jenkins2::VERSION
	s.date = Date.today
	s.summary = 'Command line interface and API client for Jenkins 2.'
	s.description = 'Command line interface and API client for Jenkins 2. Allows manipulating nodes,'\
		' jobs, plugins, credentials. See README.md for details.'
	s.authors = ['Juri Timošin']
	s.email = 'draco.ater@gmail.com'
	s.homepage = 'https://bitbucket.org/DracoAter/jenkins2'
	s.license = 'MIT'
	
	s.required_ruby_version = '~> 2.0'
	s.add_development_dependency 'rake', '~> 11.3'
	s.add_development_dependency 'minitest', '~> 5.5'
	s.add_development_dependency 'ci_reporter_minitest', '~> 1.0'
	s.add_development_dependency 'simplecov', '~> 0.10'
	s.add_development_dependency 'test-kitchen', '~> 1.17'
	s.add_development_dependency 'kitchen-lxd', '~> 0.2', '>= 0.2.2'

	s.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'bin/*', 'lib/**/*']
	s.require_path = 'lib'

	s.executables = ['jenkins2']
end
