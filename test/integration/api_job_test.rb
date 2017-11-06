require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiJobTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?><project><builders/>'\
				'<publishers/><buildWrappers/></project>'

			NEW_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>'\
				'<project><disabled>true</disabled><builders/><publishers/><buildWrappers/></project>'

			COPIED_CONFIG_XML = %{<?xml version='1.0' encoding='UTF-8'?>
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
</project>}

			PARAMETERIZED_JOB_CONFIG = %{<?xml version="1.0" encoding="UTF-8"?>
<project>
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
        <com.cloudbees.plugins.credentials.CredentialsParameterDefinition plugin="credentials@2.1.16">
          <name>cred</name>
          <description/>
          <defaultValue/>
          <credentialType>com.cloudbees.plugins.credentials.common.StandardCredentials</credentialType>
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
</project>}

			def setup
				@@subj.job( 'xml config' ).create( CONFIG_XML )
				@@subj.job( 'for deletion' ).create( NEW_CONFIG_XML )
				@@subj.job( 'parameterized' ).create( PARAMETERIZED_JOB_CONFIG )
			end
			
			def teardown
				@@subj.job( 'new one' ).delete rescue nil
				@@subj.job( 'for deletion' ).delete rescue nil
				@@subj.job( 'copied' ).delete rescue nil
				@@subj.job( 'xml config' ).delete
				@@subj.job( 'parameterized' ).delete
			end

			def test_create
				assert_equal true, @@subj.job( 'new one' ).create( CONFIG_XML )
				assert_equal 'new one', @@subj.job( 'new one' ).name
			end

			def test_copy
				assert_equal true, @@subj.job( 'copied' ).copy( 'xml config' )
				assert_equal COPIED_CONFIG_XML, @@subj.job( 'copied' ).config_xml
			end

			def test_job
				exc = assert_raises Net::HTTPServerException do
					@@subj.job( 'nonexistent' ).subject
				end
				assert_equal '404 "Not Found"', exc.message
			end

			def test_update_config_xml
				assert_equal CONFIG_XML, @@subj.job( 'xml config' ).config_xml
				assert_equal true, @@subj.job( 'xml config' ).update( NEW_CONFIG_XML )
				assert_equal NEW_CONFIG_XML, @@subj.job( 'xml config' ).config_xml
			end

			def test_delete
				assert_equal 'for deletion', @@subj.job( 'for deletion' ).name
				assert_equal true, @@subj.job( 'for deletion' ).delete
				exc = assert_raises Net::HTTPServerException do
					@@subj.job( 'for deletion' ).subject
				end
				assert_equal '404 "Not Found"', exc.message
			end

			def test_enable_disable
				assert_equal true, @@subj.job( 'xml config' ).disable
				assert_equal false, @@subj.job( 'xml config' ).buildable
				assert_equal true, @@subj.job( 'xml config' ).enable
				assert_equal true, @@subj.job( 'xml config' ).buildable
			end

			def test_build_no_params
				n_builds = @@subj.job( 'xml config' ).builds.size
				assert_equal true, @@subj.job( 'xml config' ).build
				Jenkins2::Util.wait( max_wait_minutes: 1 ) do
					!@@subj.job( 'xml config' ).inQueue and
					@@subj.job( 'xml config' ).builds.none?(&:building)
				end
				assert_equal n_builds + 1, @@subj.job( 'xml config' ).builds.size
			end

			def test_build_with_params
				n_builds = @@subj.job( 'parameterized' ).builds.size
				assert_equal true, @@subj.job( 'parameterized' ).build( str: 'test', 'bool' => true,
					cred: 'r3' )
				Jenkins2::Util.wait( max_wait_minutes: 1 ) do
					!@@subj.job( 'parameterized' ).inQueue and
					@@subj.job( 'parameterized' ).builds.none?(&:building)
				end
				assert_equal n_builds + 1, @@subj.job( 'parameterized' ).builds.size
				assert_equal( {"bool"=>true, "str"=>"test", "cred"=>nil}, @@subj.
					job( 'parameterized', depth: 3 ).builds.first.actions.first.
					parameters.each_with_object({}){|i,memo| memo[i.name] = i.value} )
			end
		end
	end
end

