# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliJobTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?><project><builders/>'\
				'<publishers/><buildWrappers/></project>'

			NEW_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>'\
				'<project><disabled>true</disabled><builders/><publishers/><buildWrappers/></project>'

			COPIED_CONFIG_XML = %(<?xml version='1.0' encoding='UTF-8'?>
<project>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class=\"hudson.scm.NullSCM\"/>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>)

			PARAMETERIZED_JOB_CONFIG = %(<?xml version="1.0" encoding="UTF-8"?><project>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.BooleanParameterDefinition>
          <name>bool</name>
          <description/>
          <defaultValue>false</defaultValue>
        </hudson.model.BooleanParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>str</name>
          <description/>
          <defaultValue/>
        </hudson.model.StringParameterDefinition>
        <com.cloudbees.plugins.credentials.CredentialsParameterDefinition plugin="credentials@\
2.1.16">
          <name>cred</name>
          <description/>
          <defaultValue/>
          <credentialType>com.cloudbees.plugins.credentials.common.StandardCredentials\
</credentialType>
          <required>false</required>
        </com.cloudbees.plugins.credentials.CredentialsParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <scm class=\"hudson.scm.NullSCM\"/>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>)

			FOLDER_XML = %(<com.cloudbees.hudson.plugins.folder.Folder plugin="cloudbees-folder@6.3">
  </com.cloudbees.hudson.plugins.folder.Folder>)

			def setup
				@@subj.job('xml cli').create(CONFIG_XML)
				@@subj.job('parameterized').create(PARAMETERIZED_JOB_CONFIG)
			end

			def teardown
				@@subj.job('xml cli').delete
				@@subj.job('parameterized').delete
			end

			def test_list_jobs
				assert_equal "parameterized\nxml cli", Jenkins2::CLI::ListJobs.new(@@opts).call
				assert_equal "parameterized\nxml cli", Jenkins2::CLI::ListJobs.new(@@opts).parse(
					['--view', 'All']
				).call
			end

			def test_copy_job
				assert_equal true, Jenkins2::CLI::CopyJob.new(@@opts).parse(
					['-f', 'xml cli', '-n', 'copied cli']
				).call
				assert_equal COPIED_CONFIG_XML, @@subj.job('copied cli').config_xml
			ensure
				@@subj.job('copied cli').delete
			end

			def test_crud_job
				assert_equal true, Jenkins2::CLI::DeleteJob.new(@@opts).parse(['-n', 'xml cli']).call
				$stdin, w = IO.pipe
				w.write(CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::CreateJob.new(@@opts).parse(['-n', 'xml cli']).call
				assert_equal 'xml cli', @@subj.job('xml cli').name
				assert_equal CONFIG_XML, Jenkins2::CLI::GetJob.new(@@opts).parse(['-n', 'xml cli']).call
				$stdin, w = IO.pipe
				w.write(PARAMETERIZED_JOB_CONFIG)
				w.close
				assert_equal true, Jenkins2::CLI::UpdateJob.new(@@opts).parse(['-n', 'xml cli']).call
				assert_equal PARAMETERIZED_JOB_CONFIG, Jenkins2::CLI::GetJob.new(@@opts).parse(
					['-n', 'xml cli']
				).call
			end

			def test_enable_disable
				assert_equal true, Jenkins2::CLI::DisableJob.new(@@opts).parse(['-n', 'xml cli']).call
				assert_equal false, @@subj.job('xml cli').buildable
				assert_equal true, Jenkins2::CLI::EnableJob.new(@@opts).parse(['-n', 'xml cli']).call
				assert_equal true, @@subj.job('xml cli').buildable
			end
		end
	end
end
