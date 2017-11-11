require 'forwardable'
require 'logger'

module Jenkins2
	class Log
		extend SingleForwardable

		def self.init( log: $stderr, verbose: 0 )
			log ||= $stderr
			@logger = Logger.new log
			@logger.level = Logger::ERROR - verbose.to_i
			@logger.formatter = proc do |severity, datetime, progname, msg|
				if log.tty?
					"#{msg}\n"
				else
					"[#{datetime.strftime '%FT%T%:z'}] #{severity} #{msg}\n"
				end
			end
			@logger
		end

		def_delegators :logger, :debug, :info, :warn, :error, :fatal, :unknown, :level

		private

		def self.logger
			@logger ||= self.init
		end
	end
end
