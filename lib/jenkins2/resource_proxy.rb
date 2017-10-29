require_relative 'util'

module Jenkins2
	class ResourceProxy #< ::BasicObject
		include Util
		attr_reader :connection, :path

		def initialize( connection, path, params={}, &block )
			@id = nil
			@connection, @path, @params = connection, URI.escape(path), params
			subject if block
		end

		def method_missing( message, *args, &block )
			subject.send(message, *args, &block)
		end

		def raw
			@raw ||= connection.get_json( build_path, @params )
		end

		def subject
			@subject ||= JSON.parse( raw.body )
		rescue JSON::ParserError
			raw.value
		end

		private

		def build_path( *sections )
			escaped_sections = [@id, sections].flatten.compact.collect{|i| URI.escape i }
			File.join( @path, *escaped_sections )
		end
	end
end
