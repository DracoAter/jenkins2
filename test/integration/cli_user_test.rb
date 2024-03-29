# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliUserTest < Minitest::Test
			def test_who_am_i
				assert_equal "id: admin\nfullName: admin\ndescription: ",
					Jenkins2::CLI::WhoAmI.new(@@opts).call
			end
		end
	end
end
