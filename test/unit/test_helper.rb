# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'

require_relative '../../lib/jenkins2'

# We do not want any logging in tests
Jenkins2::Log.init(verbose: 3)
