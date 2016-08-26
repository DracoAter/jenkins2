require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ClientCredentialTest < Minitest::Test
			PLUGINS = %w{ssh-credentials plain-credentials}
			@@subj.install_plugins PLUGINS
			@@subj.wait_plugins_installed PLUGINS
			@@redirect_url = "http://#{@@ip}:8080/credentials/store/system/domain/_"

			def test_create_credential_username_password
				assert_equal @@redirect_url, @@subj.create_credential_username_password( scope: 'GLOBAL',
					username: 'test', description: 'This is username_password credential for user test',
					id: 'uniq_Test1', password: 'secretPass' )
				assert_equal( { "description"=>"This is username_password credential for user test",
					"_class"=>"com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper",
					"displayName"=>"test/****** (This is username_password credential for user test)",
					"fingerprint"=>nil, "fullName"=>"system/_/uniq_Test1", "id"=>"uniq_Test1",
					"typeName"=>"Username with password" }, @@subj.get_credential( 'uniq_Test1' ) )
			end

			def test_create_credential_ssh
				assert_equal @@redirect_url, @@subj.create_credential_ssh( scope: 'SYSTEM', id: 'uniq_2',
					description: 'SSH for user test2', username: 'test2', private_key: "verybigprivate\nkey",
					passphrase: 'something' )
				assert_equal( { "description"=>"SSH for user test2",
					"displayName"=>"test2 (SSH for user test2)",
					"_class"=>"com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper",
					"fingerprint"=>nil, "fullName"=>"system/_/uniq_2", "id"=>"uniq_2",
					"typeName"=>"SSH Username with private key" }, @@subj.get_credential( 'uniq_2' ) )
			end

			def test_create_credential_secret_text
				assert_equal @@redirect_url, @@subj.create_credential_secret_text( scope: 'GLOBAL', id: 'r3',
					description: 'secret r3', secret: 'hello' )
				assert_equal( { "description"=>"secret r3", "displayName"=>"secret r3",
					"_class"=>"com.cloudbees.plugins.credentials.CredentialsStoreAction$CredentialsWrapper",
					"fingerprint"=>nil, "fullName"=>"system/_/r3", "id"=>"r3", "typeName"=>"Secret text"},
					@@subj.get_credential( 'r3' ) )
			end

			def test_create_credential_secret_file
				assert_equal @@redirect_url, @@subj.create_credential_secret_file( scope: 'SYSTEM',
					description: 'secret file with no id', filename: 'client.pem', content: 'secretcontent' )
				cred = @@subj.list_credentials.detect{|i| i['description'] == 'secret file with no id' }
				assert_equal "secret file with no id", cred['description']
				assert_equal "client.pem (secret file with no id)", cred["displayName"]
				assert_equal 'Secret file', cred['typeName']
				refute_nil cred['id']
				assert_equal "system/_/#{cred['id']}", cred['fullName']
			end

			def test_delete_credential
				@@subj.create_credential_ssh( scope: 'GLOBAL', id: 'delete_me',
					description: 'SSH for deletion', username: 'deleteme', private_key: "delete\nme\nkey",
					passphrase: 'delete_me' )
				refute_nil @@subj.get_credential 'delete_me'
				@@subj.delete_credential 'delete_me'
				exc = assert_raises Net::HTTPServerException do
					@@subj.get_credential 'delete_me'
				end
				assert_equal '404 "Not Found"', exc.message
			end
		end
	end
end
