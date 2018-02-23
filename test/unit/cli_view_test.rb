# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CliViewTest < Minitest::Test
			def test_add_job_to_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    add-job-to-view                  Add jobs to view.
Mandatory arguments:
    -n, --name NAME                  Name of the view.
    -j, --job X,Y,..                 Job name(s) to add.
), Jenkins2::CLI::AddJobToView.new.send(:summary)
			end

			def test_create_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-view                      Create a new view by reading stdin as an XML configuration.
Mandatory arguments:
    -n, --name NAME                  Name of the view.
), Jenkins2::CLI::CreateView.new.send(:summary)
			end

			def test_delete_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%{Command:
    delete-view                      Delete view(s).
Mandatory arguments:
    -n, --name X,Y,..                View names to delete.
}, Jenkins2::CLI::DeleteView.new.send(:summary)
			end

			def test_get_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    get-view                         Dump the view definition XML to stdout.
Mandatory arguments:
    -n, --name NAME                  Name of the view.
), Jenkins2::CLI::GetView.new.send(:summary)
			end

			def test_remove_job_from_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%{Command:
    remove-job-from-view             Remove jobs from view.
Mandatory arguments:
    -n, --name NAME                  Name of the view.
    -j, --job X,Y,..                 Job name(s) to remove.
}, Jenkins2::CLI::RemoveJobFromView.new.send(:summary)
			end

			def test_update_view_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    update-view                      Update the view definition XML from stdin. The opposite of \
the get-view command.
Mandatory arguments:
    -n, --name NAME                  Name of the view.
), Jenkins2::CLI::UpdateView.new.send(:summary)
			end
		end
	end
end
