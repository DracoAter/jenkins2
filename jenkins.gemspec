# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'jenkins/version'

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
	
	s.add_development_dependency "minitest", "~> 5.5"
	s.add_development_dependency "mocha", "~> 1.1"
	s.add_development_dependency "simplecov", "~> 0.10"
	
	s.files = `hg files`.split( "\n" ).collect(&:strip)
	s.require_path = 'lib'
	
	s.executables = ['jenkins']
end
