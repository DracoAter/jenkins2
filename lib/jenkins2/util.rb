# frozen_string_literal: true

require 'net/http'

require_relative 'log'
require_relative 'errors'

module Jenkins2
	module Util
		extend self
		# Waits for a block to return +truthful+ value. Useful, for example, when you set a node
		# temporarily offline, and then wait for it to become idle.
		# +max_wait_minutes+:: Maximum wait time in minutes.
		# +&block+:: Run this block until it returs true, max_wait_minutes pass or block throws some
		# kind of exception.
		#
		# Returns the result of a block, if it eventually succeeded or nil in case of timeout.
		#
		# Note that this is both a method of module Util, so you can <tt>include Jenkins::Util</tt>
		# into your classes so they have a #wait method, as well as a module method, so you can call it
		# directly as ::wait().
		def wait(max_wait_minutes: 60)
			[3, 5, 7, 15, 30, [60] * (max_wait_minutes - 1)].flatten.each do |sec|
				begin
					result = yield
					return result if result
					Log.warn{ "Received result is not truthy: #{result}." }
					Log.warn{ "Retry request in #{sec} seconds." }
					sleep sec
				rescue Jenkins2::NotFoundError, Jenkins2::ServiceUnavailableError => e
					Log.warn{ "Received error: #{e}." }
					Log.warn{ "Retry request in #{sec} seconds." }
					sleep sec
				end
			end
			Log.error{ "Tired of waiting (#{max_wait_minutes} minutes). Give up." }
			nil
		end

		# Tries a block several times, if raised exception is <tt>Net::HTTPFatalError</tt>,
		# <tt>Errno::ECONNREFUSED</tt> or <tt>Net::ReadTimeout</tt>.
		# +retries+:: Number of retries.
		# +retry_delay+:: Seconds to sleep, before attempting next retry.
		# +&block+:: Code to run inside <tt>retry</tt> loop.
		#
		# Returns the result of a block, if it eventually succeeded or throws the exception, thown by
		# the block on last try.
		#
		# Note that this is both a method of module Util, so you can <tt>include Jenkins::Util</tt>
		# into your classes so they have a #try method, as well as a module method, so you can call it
		# directly as ::try().
		def try(retries: 3, retry_delay: 5)
			yield
		rescue Errno::ECONNREFUSED, Net::HTTPFatalError, Net::ReadTimeout => e
			i ||= 0
			unless (i += 1) == retries
				Log.warn{ "Received error: #{e}." }
				Log.warn{ "Retry request in #{retry_delay} seconds. Retry number #{i}." }
				sleep retry_delay
				retry
			end
			Log.error{ "Received error: #{e}." }
			Log.error{ "Reached maximum number of retries (#{retries}). Give up." }
			raise e
		end
	end
end
