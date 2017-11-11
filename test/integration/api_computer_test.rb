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
				@@subj.computer( 'for deletion' ).create
				@@subj.computer( 'xml config' ).create
			end

			def teardown
				@@subj.computer( 'xml config' ).delete
				@@subj.computer( 'for deletion' ).delete rescue nil
				@@subj.computer( 'new one' ).delete rescue nil
			end

			def test_computer
				assert_includes @@subj.computer.computer.collect(&:displayName), 'master'
			end

			def test_create
				refute_includes @@subj.computer.computer.collect(&:displayName), 'new one'
				assert_equal true, @@subj.computer( 'new one' ).create
				assert_includes @@subj.computer.computer.collect(&:displayName), 'new one'
			end

			def test_delete
				assert_includes @@subj.computer.computer.collect(&:displayName), 'for deletion'
				assert_equal true, @@subj.computer( 'for deletion' ).delete
				refute_includes @@subj.computer.computer.collect(&:displayName), 'for deletion'
			end
			
			def test_get_config_xml
				assert_raises Jenkins2::BadRequestError do
					@@subj.computer('(master)').config_xml
				end
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml
			end

			def test_update
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml
				assert_equal true, @@subj.computer('xml config').update( NEW_CONFIG_XML )
				assert_equal NEW_CONFIG_XML, @@subj.computer('xml config').config_xml
				assert_equal true, @@subj.computer('xml config').update( CONFIG_XML )
				assert_equal CONFIG_XML_AFTER, @@subj.computer('xml config').config_xml
			end

			def test_idle
				assert_equal true, @@subj.computer( '(master)' ).idle
			end
		end
	end
end
