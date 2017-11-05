require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiComputerTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <label></label>
  <nodeProperties/>
</slave>'

			CONFIG_XML_AFTER = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>true</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			NEW_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>3</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>true</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			def setup
				@@subj.computer( 'xml config' ).create
			end

			def teardown
				@@subj.computer( 'xml config' ).delete
			end

			def test_computer
				assert_includes @@subj.computer['computer'].collect{|i| i['displayName'] }, 'master'
			end

			def test_create
				refute_includes @@subj.computer['computer'].collect{|i| i['displayName'] }, 'new one'
				@@subj.computer( 'new one' ).create
				assert_includes @@subj.computer['computer'].collect{|i| i['displayName'] }, 'new one'
			ensure
				@@subj.computer( 'new one' ).delete
			end

			def test_delete
				@@subj.computer( 'for deletion' ).create rescue nil
				assert_includes @@subj.computer['computer'].collect{|i| i['displayName'] }, 'for deletion'
				@@subj.computer( 'for deletion' ).delete
				refute_includes @@subj.computer['computer'].collect{|i| i['displayName'] }, 'for deletion'
			end
			
			def test_get_config_xml
				assert_raises Net::HTTPServerException do
					@@subj.computer('(master)').config_xml.code
				end
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml.body
			end

			def test_post_config_xml
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml.body
				assert_equal '200', @@subj.computer('xml config').config_xml( NEW_CONFIG_XML ).code
				assert_equal NEW_CONFIG_XML, @@subj.computer('xml config').config_xml.body
				assert_equal '200', @@subj.computer('xml config').config_xml( CONFIG_XML ).code
				assert_equal CONFIG_XML_AFTER, @@subj.computer('xml config').config_xml.body
			end

			def test_idle
				assert @@subj.computer( '(master)' )['idle']
			end
		end
	end
end
