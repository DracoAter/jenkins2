# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliViewTest < Minitest::Test
			JOB_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?><project><builders/>'\
				'<publishers/><buildWrappers/></project>'

			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<hudson.model.ListView>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
  </jobNames>
  <jobFilters/>
  <columns>
    <hudson.views.StatusColumn/>
    <hudson.views.WeatherColumn/>
    <hudson.views.JobColumn/>
    <hudson.views.LastSuccessColumn/>
    <hudson.views.LastFailureColumn/>
    <hudson.views.LastDurationColumn/>
    <hudson.views.BuildButtonColumn/>
  </columns>
  <recurse>false</recurse>
</hudson.model.ListView>'

			CONFIG_XML_WITH_NAME = '<?xml version="1.0" encoding="UTF-8"?>
<hudson.model.ListView>
  <name>cli xml config</name>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
  </jobNames>
  <jobFilters/>
  <columns>
    <hudson.views.StatusColumn/>
    <hudson.views.WeatherColumn/>
    <hudson.views.JobColumn/>
    <hudson.views.LastSuccessColumn/>
    <hudson.views.LastFailureColumn/>
    <hudson.views.LastDurationColumn/>
    <hudson.views.BuildButtonColumn/>
  </columns>
  <recurse>false</recurse>
</hudson.model.ListView>'

			NEW_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<hudson.model.ListView>
  <name>cli xml config</name>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
  </jobNames>
  <jobFilters/>
  <columns>
    <hudson.views.StatusColumn/>
    <hudson.views.WeatherColumn/>
    <hudson.views.JobColumn/>
    <hudson.views.LastFailureColumn/>
    <hudson.views.BuildButtonColumn/>
  </columns>
  <recurse>true</recurse>
</hudson.model.ListView>'

			def setup
				@@subj.view('cli xml config').create(CONFIG_XML)
			end

			def teardown
				@@subj.view('cli new one').delete rescue nil
				@@subj.view('cli xml config').delete
			end

			def test_get_view
				assert_equal CONFIG_XML_WITH_NAME, Jenkins2::CLI::GetView.new(@@opts).
					parse(['-n', 'cli xml config']).call
			end

			def test_create_view
				refute_includes @@subj.views.collect(&:name), 'cli new one'
				$stdin, w = IO.pipe
				w.write(CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::CreateView.new(@@opts).parse(['-n', 'cli new one']).call
				assert_includes @@subj.views.collect(&:name), 'cli new one'
			end

			def test_delete_view
				@@subj.view('cli for deletion').create(CONFIG_XML) rescue nil
				assert_includes @@subj.views.collect(&:name), 'cli for deletion'
				assert_equal true, Jenkins2::CLI::DeleteView.new(@@opts).parse(['-n', 'cli for deletion']).call
				refute_includes @@subj.views.collect(&:name), 'cli for deletion'
			end

			def test_update_view
				assert_equal CONFIG_XML_WITH_NAME, @@subj.view('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(NEW_CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::UpdateView.new(@@opts).parse(['-n', 'cli xml config']).call
				assert_equal NEW_CONFIG_XML, @@subj.view('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::UpdateView.new(@@opts).parse(['-n', 'cli xml config']).call
				assert_equal CONFIG_XML_WITH_NAME, @@subj.view('cli xml config').config_xml
			end

			def test_add_remove_job
				@@subj.job('empty job').create(JOB_CONFIG_XML)
				refute_includes @@subj.view('cli xml config').jobs.collect(&:name), 'empty job'
				assert_equal true, Jenkins2::CLI::AddJobToView.new(@@opts).parse(
					['-n', 'cli xml config', '-j', 'empty job']
				).call
				assert_includes @@subj.view('cli xml config').jobs.collect(&:name), 'empty job'
				assert_equal true, Jenkins2::CLI::RemoveJobFromView.new(@@opts).parse(
					['-n', 'cli xml config', '-j', 'empty job']
				).call
				refute_includes @@subj.view('cli xml config').jobs.collect(&:name), 'empty job'
			ensure
				@@subj.job('empty job').delete rescue nil
			end
		end
	end
end
