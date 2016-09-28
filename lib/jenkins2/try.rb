require 'net/http'

require_relative 'log'

module Jenkins2
	module Try
		# Tries a block several times, if raised exception is <tt>Net::HTTPFatalError</tt>,
		# <tt>Errno::ECONNREFUSED</tt> or <tt>Net::ReadTimeout</tt>.
		# +retries+:: Number of retries.
		# +retry_delay+:: Seconds to sleep, before attempting next retry.
		# +&block+:: Code to run inside <tt>retry</tt> loop.
		#
		# Returns the result of a block, if it eventually succeeded or throws the exception, thown by
		# the block on last try.
		#
		# Note that this is both a method of module Try, so you can <tt>include Jenkins::Try</tt>
		# into your classes so they have a #try method, as well as a module method, so you can call it
		# directly as ::try().
		def try( retries: 3, retry_delay: 5, &block )
			yield
		rescue Errno::ECONNREFUSED, Net::HTTPFatalError, Net::ReadTimeout => e
			i ||= 0
			unless ( i += 1 ) == retries
				Log.warn { "Received error: #{e}." }
				Log.warn { "Retrying request in #{retry_delay} seconds." }
				sleep retry_delay
				retry
			end
			Log.error { "Reached maximum number of retries (#{retries}). Giving up." }
			raise e
		rescue StandardError => e
			Log.warn { "Received (fatal) error: #{e}." }
			raise e
		end

		module_function :try
	end
end
