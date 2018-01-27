require_relative 'resource_proxy'
require_relative 'connection'
require_relative 'errors'
require_relative 'util'
require_relative 'api/credentials'
require_relative 'api/computer'
require_relative 'api/job'
require_relative 'api/plugins'
require_relative 'api/root'
require_relative 'api/user'
require_relative 'api/view'

module Jenkins2
	class API
		include Credentials
		include Computer
		include Job
		include Plugins
		include Root
		include User
		include View

		attr_reader :connection

		def initialize( **options )
			@connection = Jenkins2::Connection.new( options[:server] ).
				basic_auth options[:user], options[:key]
			Log.init( log: options[:log], verbose: options[:verbose] )
		end
	end
end
