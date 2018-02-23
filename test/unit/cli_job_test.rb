# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CliJobTest < Minitest::Test
			def test_list_jobs_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    list-jobs                        List all jobs in a specific view or item group.
Optional arguments:
        --view VIEW                  Name of the view. Default - All.
), Jenkins2::CLI::ListJobs.new.send(:summary)
			end

			def test_copy_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    copy-job                         Copy a job.
Mandatory arguments:
    -f, --from NAME                  Name of the job to copy from.
    -n, --name NAME                  Name of the new job.
), Jenkins2::CLI::CopyJob.new.send(:summary)
			end

			def test_create_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-job                       Create a new job by reading stdin as an XML configuration.
Mandatory arguments:
    -n, --name NAME                  Name of the new job.
), Jenkins2::CLI::CreateJob.new.send(:summary)
			end

			def test_delete_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    delete-job                       Delete a job.
Mandatory arguments:
    -n, --name NAME                  Name of the job.
), Jenkins2::CLI::DeleteJob.new.send(:summary)
			end

			def test_disable_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    disable-job                      Disable a job, restrict all builds of the job from now on.
Mandatory arguments:
    -n, --name NAME                  Name of the job.
), Jenkins2::CLI::DisableJob.new.send(:summary)
			end

			def test_enable_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    enable-job                       Enable job, allow building the job. Cancels previously \
issued "disable-job".
Mandatory arguments:
    -n, --name NAME                  Name of the job.
), Jenkins2::CLI::EnableJob.new.send(:summary)
			end

			def test_get_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    get-job                          Dump the job definition XML to stdout.
Mandatory arguments:
    -n, --name NAME                  Name of the job.
), Jenkins2::CLI::GetJob.new.send(:summary)
			end

			def test_update_job_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    update-job                       Update the job definition XML from stdin. The opposite of \
the "get-job" command.
Mandatory arguments:
    -n, --name NAME                  Name of the job.
), Jenkins2::CLI::UpdateJob.new.send(:summary)
			end
		end
	end
end
