require_relative 'jenkins2/api'

module Jenkins2
	def self.connect( **opts )
		Jenkins2::API.new opts
	end
end
