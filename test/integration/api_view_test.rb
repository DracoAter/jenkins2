# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiViewTest < Minitest::Test
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
  <name>xml config</name>
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
  <name>xml config</name>
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
				@@subj.view('xml config').create(CONFIG_XML)
			end

			def teardown
				@@subj.view('new one').delete rescue nil
				@@subj.view('xml config').delete
			end

			def test_view
				assert_equal 'all', @@subj.view('All').name
			end

			def test_views
				assert_includes @@subj.views.collect(&:name), 'all'
			end

			def test_create
				refute_includes @@subj.views.collect(&:name), 'new one'
				assert_equal true, @@subj.view('new one').create(CONFIG_XML)
				assert_includes @@subj.views.collect(&:name), 'new one'
			end

			def test_delete
				@@subj.view('for deletion').create(CONFIG_XML) rescue nil
				assert_includes @@subj.views.collect(&:name), 'for deletion'
				assert_equal true, @@subj.view('for deletion').delete
				refute_includes @@subj.views.collect(&:name), 'for deletion'
			end

			def test_config_xml
				assert_equal CONFIG_XML_WITH_NAME, @@subj.view('xml config').config_xml
			end

			def test_update
				assert_equal CONFIG_XML_WITH_NAME, @@subj.view('xml config').config_xml
				assert_equal true, @@subj.view('xml config').update(NEW_CONFIG_XML)
				assert_equal NEW_CONFIG_XML, @@subj.view('xml config').config_xml
				assert_equal true, @@subj.view('xml config').update(CONFIG_XML)
				assert_equal CONFIG_XML_WITH_NAME, @@subj.view('xml config').config_xml
			end

			def test_add_remove_job
				@@subj.job('empty job').create(JOB_CONFIG_XML)
				refute_includes @@subj.view('xml config').jobs.collect(&:name), 'empty job'
				assert_equal true, @@subj.view('xml config').add_job('empty job')
				assert_includes @@subj.view('xml config').jobs.collect(&:name), 'empty job'
				assert_equal true, @@subj.view('xml config').remove_job('empty job')
				refute_includes @@subj.view('xml config').jobs.collect(&:name), 'empty job'
			ensure
				@@subj.job('empty job').delete rescue nil
			end
		end
	end
end
