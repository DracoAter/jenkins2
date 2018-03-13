# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'

require_relative '../../lib/jenkins2'

# Tests can be super verbose, but should write into some file
Jenkins2::Log.init(log: 'test/unit.log', verbose: 3)
