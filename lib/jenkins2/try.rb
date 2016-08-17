require 'net/http'

require_relative 'log'

module Jenkins2
	module Try

		# Tries a block several times, if raised exceptions are <tt>Net::HTTPClientError</tt> or
		# <tt>Net::HTTPServerError</tt>.
		# +retries+:: Number of retries.
		# +retry_delay+:: Seconds to sleep, before attempting next retry.
		# +&block+:: Code to run inside <tt>retry</tt> loop.
		def self.try( retries: 3, retry_delay: 5, &block )
			yield
		rescue Net::HTTPClientError, Net::HTTPServerError => e
			unless ( retries -= 1 ).zero?
				Log.error { "Retrying request in #{retry_delay} seconds." }
				sleep retry_delay
				retry
			end
			Log.error { "Reached maximum number of retries (#{retries}). Giving up." }
			raise e
		end
	end
end
