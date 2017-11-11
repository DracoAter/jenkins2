require_relative 'resource_proxy'
require_relative 'errors'
require_relative 'api/credentials'
require_relative 'api/computer'
require_relative 'api/job'
require_relative 'api/plugins'
require_relative 'api/root'
require_relative 'api/user'
require_relative 'api/view'

module Jenkins2
	class Client
		include Jenkins2::API::Credentials
		include Jenkins2::API::Computer
		include Jenkins2::API::Job
		include Jenkins2::API::Plugins
		include Jenkins2::API::Root
		include Jenkins2::API::User
		include Jenkins2::API::View

		attr_reader :connection

		def initialize( **options )
			@connection = Jenkins2::Connection.new( options[:server] ).
				basic_auth options[:user], options[:key]
			Log.init( log: options[:log], verbose: options[:verbose] )
		end
	end
end
