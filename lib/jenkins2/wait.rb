require 'net/http'

require_relative 'log'

module Jenkins2
	module Wait
		# Waits for a block to return +truthful+ value. Useful, for example, when you set a node tenporarily
		# offline, and then wait for it to become idle.
		# +max_wait_minutes+:: Maximum wait time in minutes.
		# +&block+:: Run this block until it returs true, max_wait_minutes pass or block throws some
		# kind of exception.
		#
		# Returns the result of a block, if it eventually succeeded or nil in case of timeout.
		#
		# Note that this is both a method of module Wait, so you can <tt>include Jenkins::Wait</tt>
		# into your classes so they have a #wait method, as well as a module method, so you can call it
		# directly as ::wait().
		def wait( max_wait_minutes: 60, &block )
			[3, 5, 7, 15, 30, [60] * (max_wait_minutes - 1)].flatten.each do |sec|
				result = yield
				return result if result
				sleep sec
			end
			nil
		end

		module_function :wait
	end
end
