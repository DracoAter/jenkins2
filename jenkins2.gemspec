# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require_relative 'lib/jenkins2/version'

Gem::Specification.new do |s|
	s.name = 'jenkins2'
	s.version = Jenkins2::VERSION
	s.date = '2016-07-27'
	s.summary = 'Ruby and command line integrations for Jenkins 2 (client, API, CLI etc.)'
	s.description = 'Ruby and command line integrations for Jenkins 2 (client, API, CLI etc.)'
	s.authors = ['Juri Timošin']
	s.email = 'draco.ater@gmail.com'
	s.homepage = 'https://bitbucket.org/DracoAter/jenkins2'
	s.license = 'MIT'
	
	#lol - required for validation
	s.rubyforge_project = 'jenkins2'
	
	s.required_ruby_version = '~> 2.3'
	s.add_development_dependency 'minitest', '~> 5.5'
	s.add_development_dependency 'ci_reporter_minitest', '~> 1.0'
	s.add_development_dependency 'mocha', '~> 1.1'
	s.add_development_dependency 'simplecov', '~> 0.10'
	
	s.files = Dir['LICENSE', 'README.md', 'bin/*', 'lib/**/*']
	s.require_path = 'lib'
	
	s.executables = ['jenkins2']
end
