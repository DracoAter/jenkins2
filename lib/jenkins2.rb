# frozen_string_literal: true

require_relative 'jenkins2/api'
require_relative 'jenkins2/cli'

module Jenkins2
	def self.connect(**opts)
		Jenkins2::API.new opts
	end
end
