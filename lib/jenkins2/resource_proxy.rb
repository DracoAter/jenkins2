module Jenkins2
	class ResourceProxy #< ::BasicObject
		attr_reader :connection, :path

		def initialize( connection, path, params={}, &block )
			unless params.is_a? ::Hash
				@id = params
				params = {}
			end
			@connection, @path, @params = connection, URI.escape(path), params
			@block = block if block
			subject if block
		end

		def method_missing( message, *args, &block )
			p "message=#{message}, args=#{args}"
			subject.send(message, *args, &block)
		end

		def subject
			@subject ||= connection.get( path, @params )
		end

		private

		def build_path( endpoint, id='' )
			File.join( @path, endpoint, id )
		end
	end
end
