# frozen_string_literal: true

require 'erb'

require_relative 'util'

module Jenkins2
	class ResourceProxy < ::BasicObject
		attr_reader :connection, :path

		def initialize(connection, path, params={}, &block)
			@path = path
			@id = nil
			@connection, @params = connection, params
			subject if block
		end

		def method_missing(message, *args, &block)
			if respond_to_missing? message
				::Jenkins2::Log.debug message
				subject.send(message, *args, &block)
			else
				super
			end
		end

		def respond_to_missing?(method_name, include_private=false)
			subject.respond_to? method_name, include_private
		end

		def raw
			@raw ||= connection.get_json(build_path, @params)
		end

		def subject
			@subject ||= ::JSON.parse(raw.body, object_class: ::OpenStruct)
		end

		private

		def build_path(*sections)
			escaped_sections = [@id, sections].flatten.compact.collect{|i| ::ERB::Util.url_encode i }
			::File.join(@path, *escaped_sections)
		end
	end
end
