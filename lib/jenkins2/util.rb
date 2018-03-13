# frozen_string_literal: true

require 'net/http'

require_relative 'log'
require_relative 'errors'

module Jenkins2
	module Util
		extend self
		# Attempt to run a block multiple times rescuing exceptions until 1 of those conditions are
		# true:
		# - +times+ is set and number of attempts done equals to +times+.
		# - +max_wait+ is set and total time spent in sleep exceeded +max_wait+.
		# - +success+ is set and result of running block equals to +success+.
		# ==== Parameters:
		# +times+:: Number of attempts to make to run the block including initial attempt.
		# +intervals+:: Array of intervals in seconds. Last interval can be used several times until
		#   we run out of attempts or exceed +max_wait+ time.
		# +on+:: Excepton class or array of exception classes on which to retry. Default is -
		#   StandardError.
		# +max_wait:: Max amount of total time in seconds allowed to spend waiting. If both +times+
		#   and +max_wait+ are not set, +max_wait+ will be set to 300 (5 minutes).
		# +success+:: Acceptable result. Make attempts until block returns value equal to +success+.
		# ==== Returns:
		# Result of block call, or raises same Error, that block raised after +max_wait+ or +times+
		# exceeded.
		# ==== Examples:
		#
		def attempt(times: nil, intervals: [1, 2, 4, 8, 15, 30, 60], on: StandardError,
			max_wait: nil, success: nil)
			intervals = [intervals].flatten
			intervals_enum = Enumerator.new do |y|
				intervals.each{|i| y << i }
				loop{ y << intervals.last }
			end

			started_at = Time.now
			elapsed_time = proc{ Time.now - started_at }
			max_wait = 300 if times.nil? and max_wait.nil?

			Log.info{ 'Will make several attempts. Attempt #1.' }
			intervals_enum.with_index 2 do |int, ind|
				sleep_time = proc{ max_wait ? [max_wait - elapsed_time.call, int].min : int }
				begin
					result = yield
					if success.nil? or success == result
						Log.info{ 'Attempt successful.' }
						return result
					end
					Log.warn{ "Received: #{result.inspect}, but we are expecting #{success.inspect}." }
					next_try_in = sleep_time.call
					Log.warn{ "Next attempt (##{ind}) in #{next_try_in} seconds." }
					sleep next_try_in
				rescue *[on].flatten => e
					if times and ind > times
						Log.error{ "Received error: #{e}." }
						Log.error{ "Reached maximum number of attempts (#{ind}). Give up." }
						raise e
					elsif max_wait and elapsed_time.call >= max_wait
						Log.error{ "Received error: #{e}." }
						Log.error{ "Tired of waiting (#{elapsed_time.call} seconds). Give up." }
						raise e
					else
						Log.warn{ "Received error: #{e}." }
						next_try_in = sleep_time.call
						Log.warn{ "Next attempt (##{ind}) in #{next_try_in} seconds." }
						sleep next_try_in
					end
				end
			end
		end

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
