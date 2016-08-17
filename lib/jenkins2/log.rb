require 'forwardable'
require 'logger'

module Jenkins2
	class Log
		extend SingleForwardable

		def self.init( log: STDOUT, verbose: 0 )
			@logger = Logger.new log
			@logger.level = Logger::ERROR - verbose
			@logger.datetime_format = '%Y-%m-%d %H:%M:%S'
			@logger.formatter = proc do |severity, datetime, progname, msg|
				if log == STDOUT
					"#{msg}\n"
				else
					"[#{datetime}] #{severity} #{msg}\n"
				end
			end
			@logger
		end

		def_delegators :logger, :debug, :info, :warn, :error, :fatal, :unknown

		private

		def self.logger
			@logger ||= self.init
		end
	end
end
