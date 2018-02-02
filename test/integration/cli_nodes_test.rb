# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliNodesTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>%<name>s</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <label></label>
  <nodeProperties/>
</slave>'

			CONFIG_XML_AFTER = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>cli xml config</name>
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
  <name>cli xml config</name>
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
				@@subj.computer('cli xml config').create
				@@subj.computer('cli for deletion').create
			end

			def teardown
				@@subj.computer('cli for deletion').delete rescue nil
				@@subj.computer('cli new one').delete rescue nil
				@@subj.computer('cli xml config').delete
			end

			def test_create_node
				refute_includes @@subj.computer.computer.collect(&:displayName), 'cli new one'
				$stdin, w = IO.pipe
				w.write(format(CONFIG_XML, name: 'cli new one'))
				w.close
				assert_equal true, Jenkins2::CLI::CreateNode.new(@@opts.merge(name: 'cli new one')).call
				assert_includes @@subj.computer.computer.collect(&:displayName), 'cli new one'
			end

			def test_delete
				assert_includes @@subj.computer.computer.collect(&:displayName), 'cli for deletion'
				assert_equal true, Jenkins2::CLI::DeleteNode.new(@@opts.merge(name: ['cli for deletion'])).call
				refute_includes @@subj.computer.computer.collect(&:displayName), 'cli for deletion'
			end

			def test_get_node
				assert_raises Jenkins2::BadRequestError do
					Jenkins2::CLI::GetNode.new(@@opts.merge(name: '(master)')).call
				end
				assert_equal format(CONFIG_XML, name: 'cli xml config'), Jenkins2::CLI::GetNode.new(
					@@opts.merge(name: 'cli xml config')
				).call
			end

			def test_update_node
				assert_equal format(CONFIG_XML, name: 'cli xml config'),
					@@subj.computer('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(NEW_CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::UpdateNode.new(@@opts.merge(name: 'cli xml config')).call
				assert_equal NEW_CONFIG_XML, @@subj.computer('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(format(CONFIG_XML, name: 'cli xml config'))
				w.close
				assert_equal true, Jenkins2::CLI::UpdateNode.new(@@opts.merge(name: 'cli xml config')).call
				assert_equal format(CONFIG_XML, name: 'cli xml config'),
					@@subj.computer('cli xml config').config_xml
			end
		end
	end
end
