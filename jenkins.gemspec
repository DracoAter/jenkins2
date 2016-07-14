# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require_relative 'lib/jenkins/version'

Gem::Specification.new do |s|
	s.name = 'jenkins'
	s.version = Jenkins::VERSION
	s.date = '2015-07-20'
	s.summary = 'Ruby and command line integrations for Jenkins (client, API, CLI etc.)'
	s.description = 'Ruby and command line integrations for Jenkins (client, API, CLI etc.)'
	s.authors = ['Juri Timošin']
	s.email = 'draco.ater@gmail.com'
	s.homepage = 'http://rubygems.org/gems/jenkins'
	s.license = 'MIT'
	
	#lol - required for validation
	s.rubyforge_project = 'jenkins'
	
	s.required_ruby_version = '~> 2.3'
	s.add_development_dependency 'minitest', '~> 5.5'
	s.add_development_dependency 'ci_reporter_minitest', '~> 1.0'
	s.add_development_dependency 'mocha', '~> 1.1'
	s.add_development_dependency 'simplecov', '~> 0.10'
	
	s.files = Dir['LICENSE', 'README.md', 'bin/*', 'lib/**/*']
	s.require_path = 'lib'
	
	s.executables = ['jenkins']
end
