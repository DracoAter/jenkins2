# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliCredentialsTest < Minitest::Test
			OUTPUT_XML = %(<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl \
plugin="credentials@2.1.16">
  <scope>GLOBAL</scope>
  <id>cli_uniq_Test1</id>
  <description>This is username_password credential for user cli test</description>
  <username>cli test</username>
  <password>
    <secret-redacted/>
  </password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>)

			SECRET_XML = %(<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl \
plugin="plain-credentials@1.4">
  <scope>GLOBAL</scope>
  <id>cli crud</id>
  <description>hello desc</description>
  <secret>
    uniqstring
  </secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>)

			DOMAIN_XML = %(<com.cloudbees.plugins.credentials.domains.Domain plugin="credentials@2.1.16">
  <name>cli create</name>
  <description>this is desc</description>
</com.cloudbees.plugins.credentials.domains.Domain>)

			def setup
				@@subj.credentials.store('system').domain('_', depth: 1).create_username_password(
					scope: 'GLOBAL', username: 'cli test',
					description: 'This is username_password credential for user cli test',
					id: 'cli_uniq_Test1', password: 'secretPass'
				)
			end

			def teardown
				@@subj.credentials.store('system').domain('_', depth: 1).
					credential('cli_uniq_Test1').delete
			end

			def test_cli_domain_crud
				@@subj.credentials.store('system').domain('cli create').delete rescue nil
				assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::GetCredentialsDomainAsXml.new(@@opts).parse(
						['--store', 'system', '--domain', 'cli create']
					).call
				end
				$stdin, w = IO.pipe
				w.write(DOMAIN_XML)
				w.close
				assert_equal true, Jenkins2::CLI::CreateCredentialsDomainByXml.new(@@opts).
					parse(['--store', 'system']).call
				assert_equal DOMAIN_XML, Jenkins2::CLI::GetCredentialsDomainAsXml.new(@@opts).parse(
					['--store', 'system', '--domain', 'cli create']
				).call
				$stdin, w = IO.pipe
				w.write(DOMAIN_XML.sub('this is', 'hello'))
				w.close
				assert_equal true, Jenkins2::CLI::UpdateCredentialsDomainByXml.new(@@opts).
					parse(['--store', 'system', '--domain', 'cli create']).call
				assert_includes Jenkins2::CLI::GetCredentialsDomainAsXml.new(@@opts).parse(
					['--store', 'system', '--domain', 'cli create']
				).call, 'hello desc'
				assert_equal true, Jenkins2::CLI::DeleteCredentialsDomain.new(@@opts).
					parse(['--store', 'system', '--domain', 'cli create']).call
				assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::GetCredentialsDomainAsXml.new(@@opts).parse(
						['--store', 'system', '--domain', 'cli create']
					).call
				end
			end

			def test_cli_credential_crud
				@@subj.credentials.store('system').domain('_').credential('cli crud').delete rescue nil
				assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::GetCredentialsAsXml.new(@@opts).parse(
						['--store', 'system', '--domain', '_', '--credential', 'cli crud']
					).call
				end
				$stdin, w = IO.pipe
				w.write(SECRET_XML)
				w.close
				assert_equal true, Jenkins2::CLI::CreateCredentialsByXml.new(@@opts).
					parse(['--store', 'system', '--domain', '_']).call
				assert_equal SECRET_XML.sub('uniqstring', '<secret-redacted/>'),
					Jenkins2::CLI::GetCredentialsAsXml.new(@@opts).parse(
						['--store', 'system', '--domain', '_', '--credential', 'cli crud']
					).call
				$stdin, w = IO.pipe
				w.write(SECRET_XML.sub('hello', 'bye'))
				w.close
				assert_equal true, Jenkins2::CLI::UpdateCredentialsByXml.new(@@opts).
					parse(['--store', 'system', '--domain', '_', '--credential', 'cli crud']).call
				assert_includes Jenkins2::CLI::GetCredentialsAsXml.new(@@opts).parse(
					['--store', 'system', '--domain', '_', '--credential', 'cli crud']
				).call, 'bye desc'
				assert_equal true, Jenkins2::CLI::DeleteCredentials.new(@@opts).
					parse(['--store', 'system', '--domain', '_', '--credential', 'cli crud']).call
				assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::GetCredentialsAsXml.new(@@opts).parse(
						['--store', 'system', '--domain', '_', '--credential', 'cli crud']
					).call
				end
			end

			def test_list_credentials
				result = Jenkins2::CLI::ListCredentials.new(@@opts).parse(['--store', 'system']).call
				assert_includes result, 'Domain: Global credentials (unrestricted)'
				assert_includes result, 'cli_uniq_Test1 - cli test/****** (This is username_password '\
					'credential for user cli test)'
			end
		end
	end
end
