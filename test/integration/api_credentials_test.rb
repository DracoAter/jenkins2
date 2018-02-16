# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiCredentialsTest < Minitest::Test
			SECRET_TEXT = %(<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl \
plugin="plain-credentials@1.4">
  <scope>GLOBAL</scope>
  <id>api uniq 1</id>
  <description>secret</description>
  <secret>somesecrettext</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>)

			DOMAIN_XML = %(<com.cloudbees.plugins.credentials.domains.Domain plugin="credentials@2.1.16">
  <name>api create</name>
  <description>this is desc</description>
</com.cloudbees.plugins.credentials.domains.Domain>)

			def setup
				@subj = @@subj.credentials.store('system').domain('_', depth: 1)
				@subj.create(SECRET_TEXT)
			end

			def teardown
				@subj.credential('api uniq 1').delete
			end

			def test_domain_crud
				subj = @@subj.credentials.store('system')
				subj.domain('api create').delete rescue nil
				assert_raises Jenkins2::NotFoundError do
					subj.domain('api create').to_h
				end
				assert_equal true, subj.create_domain(DOMAIN_XML)
				assert_equal(
					{
						_class: 'com.cloudbees.plugins.credentials.CredentialsStoreAction$DomainWrapper',
						credentials: [], description: 'this is desc', displayName: 'api create',
						fullDisplayName: 'System » api create', fullName: 'system/api%20create',
						global: false, urlName: 'api%20create'
					}, subj.domain('api create').to_h
				)
				assert_equal DOMAIN_XML, subj.domain('api create').config_xml
				assert_equal true, subj.domain('api create').update(DOMAIN_XML.sub('this is', 'hello'))
				assert_equal 'hello desc', subj.domain('api create').description
				assert_equal true, subj.domain('api create').delete
				assert_raises Jenkins2::NotFoundError do
					subj.domain('api create').to_h
				end
			end

			def test_create_username_password
				assert_equal true, @subj.create_username_password(scope: 'GLOBAL',
					username: 'test', description: 'This is username_password credential for user test',
					id: 'uniq_Test1', password: 'secretPass')
				assert_equal({
					description: 'This is username_password credential for user test',
					_class: 'com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper',
					displayName: 'test/****** (This is username_password credential for user test)',
					fingerprint: nil, fullName: 'system/_/uniq_Test1', id: 'uniq_Test1',
					typeName: 'Username with password'
				}, @subj.credential('uniq_Test1').to_h)
			end

			def test_create_ssh
				assert_equal true, @subj.create_ssh(scope: 'SYSTEM', id: 'uniq_2',
					description: 'SSH for user test2', username: 'test2', private_key: 'verybigprivate\nkey',
					passphrase: 'something')
				assert_equal({
					description: 'SSH for user test2', id: 'uniq_2',
					displayName: 'test2 (SSH for user test2)', fingerprint: nil, fullName: 'system/_/uniq_2',
					_class: 'com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper',
					typeName: 'SSH Username with private key'
				}, @subj.credential('uniq_2').to_h)
			end

			def test_create_secret_text
				assert_equal true, @subj.create_secret_text(scope: 'GLOBAL', id: 'r3',
					description: 'secret r3', secret: 'hello')
				assert_equal({
					description: 'secret r3', displayName: 'secret r3',
					_class: 'com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper',
					fingerprint: nil, fullName: 'system/_/r3', id: 'r3', typeName: 'Secret text'
				}, @subj.credential('r3').to_h)
			end

			def test_create_secret_file
				assert_equal true, @subj.create_secret_file(scope: 'SYSTEM', filename: 'client.pem',
					description: 'secret file with no id', content: 'secretcontent')
				cred = @subj.credentials.detect{|i| i.description == 'secret file with no id' }
				assert_equal 'secret file with no id', cred.description
				assert_equal 'client.pem (secret file with no id)', cred.displayName
				assert_equal 'Secret file', cred.typeName
				refute_nil cred.id
				assert_equal "system/_/#{cred.id}", cred.fullName
			end

			def test_config_xml
				assert_equal SECRET_TEXT.sub('somesecrettext', "\n    <secret-redacted/>\n  "),
					@subj.credential('api uniq 1').config_xml
			end

			def test_update
				assert_equal 'secret', @subj.credential('api uniq 1').description
				assert_equal true, @subj.credential('api uniq 1').update(SECRET_TEXT.sub('secret', 'hello'))
				assert_equal 'hello', @subj.credential('api uniq 1').description
			end

			def test_create
				@subj.credential('api uniq 1').delete
				assert_equal false, @subj.credentials.collect(&:id).include?('api uniq 1')
				assert_equal true, @subj.create(SECRET_TEXT)
				refute_nil @subj.credential('api uniq 1')
			end

			def test_delete_credential
				assert_equal true, @subj.create_ssh(scope: 'GLOBAL', id: 'delete_me',
					description: 'SSH for deletion', username: 'deleteme', private_key: "delete\nme\nkey",
					passphrase: 'delete_me')
				refute_nil @subj.credential('delete_me').subject
				assert_equal true, @subj.credential('delete_me').delete
				exc = assert_raises Jenkins2::NotFoundError do
					@subj.credential('delete_me').subject
				end
				assert_equal 'Problem accessing /credentials/store/system/domain/_/credential/delete_me/'\
					'api/json.', exc.message
			end
		end
	end
end
