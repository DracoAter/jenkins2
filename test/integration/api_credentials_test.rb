# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiCredentialsTest < Minitest::Test
			PLUGINS = %w[ssh-credentials plain-credentials].freeze
			@@subj.plugins.install PLUGINS
			Jenkins2::Util.wait do
				@@subj.plugins(depth: 1).plugins.select{|p| PLUGINS.include? p.shortName }.all?(&:active)
			end

			def setup
				@subj = @@subj.credentials.store('system').domain('_', depth: 1)
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
