require 'erb'

require_relative 'util'

module Jenkins2
	class ResourceProxy #< ::BasicObject
		attr_reader :connection, :path

		def initialize( connection, path, params={}, &block )
			encoded_path = path.split('/').collect{|i| ::ERB::Util.url_encode i}.join('/')
			@id = nil
			@connection, @path, @params = connection, encoded_path, params
			subject if block
		end

		def method_missing( message, *args, &block )
			::Jenkins2::Log.debug message
			subject.send(message, *args, &block)
		end

		def raw
			@raw ||= connection.get_json( build_path, @params )
		end

		def subject
			@subject ||= ::JSON.parse( raw.body, object_class: ::OpenStruct  )
		rescue ::JSON::ParserError
			raw.value
		end

		private

		def build_path( *sections )
			escaped_sections = [@id, sections].flatten.compact.collect{|i| ::ERB::Util.url_encode i }
			::File.join( @path, *escaped_sections )
		end
	end
end
