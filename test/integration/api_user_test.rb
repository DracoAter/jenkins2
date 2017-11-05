require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiUserTest < Minitest::Test
			def test_me
				assert_equal 'admin', @@subj.me.fullName
			end

			def test_user
				assert_equal 'admin', @@subj.user( 'admin' ).fullName
			end

			def test_people
				assert_equal ['admin'], @@subj.people.users.collect(&:user).collect(&:fullName)
			end
		end
	end
end
