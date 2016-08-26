require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
	add_filter '/test/'
end

require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/jenkins2'
