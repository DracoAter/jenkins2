module Jenkins2
	module API
		module Credentials
			def credentials( params={} )
				Proxy.new connection, "credentials", params
			end

			class Proxy < ::Jenkins2::ResourceProxy
				def store( id, params={} )
					path = build_path 'store', id
					Store::Proxy.new connection, path, params
				end
			end

			module Store
				class Proxy < ::Jenkins2::ResourceProxy
					def domain( id, params={} )
						path = build_path 'domain', id
						Domain::Proxy.new connection, path, params
					end
				end

				module Domain
					class Proxy < ::Jenkins2::ResourceProxy
						BOUNDARY = '----Jenkins2RubyMultipartClient' + rand(1000000).to_s

						# Creates ssh username with private key credentials. Jenkins must have ssh-credentials plugin
						# installed, to use this functionality. Accepts the following key-word parameters.
						# +scope+:: Scope of the credential. GLOBAL or SYSTEM
						# +id+:: Id of the credential. Will be Generated by Jenkins, if not provided.
						# +description+:: Human readable text, what this credential is used for.
						# +username+:: Ssh username.
						# +private_key+:: Ssh private key, with new lines replaced by <tt>\n</tt> sequence.
						# +passphrase+:: Passphrase for the private key. Empty string, if not provided.
						def create_ssh( username:, private_key:, scope: 'global', id: nil, description: nil, passphrase: nil )
							json_body = { "" => "1",
								credentials: {
									scope: scope,
									username: username,
									privateKeySource: {
										value: "0",
										privateKey: private_key,
										'stapler-class' => 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource'
									},
									passphrase: passphrase,
									id: id,
									description: description,
									'$class' => 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey'
								}
							}.to_json
							create( "json=#{::CGI.escape json_body}" )
						end

						# Creates a secret text credential. Jenkins must have plain-credentials plugin
						# installed, to use this functionality. Accepts hash with the following parameters.
						# +scope+:: Scope of the credential. GLOBAL or SYSTEM
						# +id+:: Id of the credential. Will be Generated by Jenkins, if not provided.
						# +description+:: Human readable text, what this credential is used for.
						# +secret+:: Some secret text.
						def create_secret_text( **args )
							json_body = { "" => "3",
								credentials: args.merge(
									'$class' => 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl'
								)
							}.to_json
							create( "json=#{::CGI.escape json_body}" )
						end

						# Creates a secret file credential. Jenkins must have plain-credentials plugin
						# installed, to use this functionality. Accepts hash with the following parameters.
						# +scope+:: Scope of the credential. GLOBAL or SYSTEM
						# +id+:: Id of the credential. Will be Generated by Jenkins, if not provided.
						# +description+:: Human readable text, what this credential is used for.
						# +filename+:: Name of the file.
						# +content+:: File content.
						def create_secret_file( **args )
							filename = args.delete :filename
							content = args.delete :content
							body = "--#{BOUNDARY}\r\n"
							body << "Content-Disposition: form-data; name=\"file0\"; filename=\"#{filename}\"\r\n"
							body << "Content-Type: application/octet-stream\r\n\r\n"
							body << content
							body << "\r\n"
							body << "--#{BOUNDARY}\r\n"
							body << "Content-Disposition: form-data; name=\"json\"\r\n\r\n"
							body << { "" => "2",
								credentials: args.merge(
									'$class' => 'org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl',
									'file' => 'file0'
								)
							}.to_json
							body << "\r\n\r\n--#{BOUNDARY}--\r\n"
							create( body, "multipart/form-data, boundary=#{BOUNDARY}" )
						end

						# Creates username and password credential. Accepts hash with the following parameters.
						# +scope+:: Scope of the credential. GLOBAL or SYSTEM
						# +id+:: Id of the credential. Will be Generated by Jenkins, if not provided.
						# +description+:: Human readable text, what this credential is used for.
						# +username+:: Username.
						# +password+:: Password in plain text.
						def create_username_password( **args )
							json_body = { "" => "0",
								credentials: args.merge(
									'$class' => 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
								)
							}.to_json
							create( "json=#{::CGI.escape json_body}" )
						end

						def create( body, content_type='application/x-www-form-urlencoded' )
							path = build_path 'createCredentials'
							connection.post( path, body ) do |req|
								req['Content-Type'] = content_type
							end
						end

						# Returns credential as json. Raises Net::HTTPNotFound, if no such credential
						# +id+:: Credential's id
						def credential( id, params={} )
							path = build_path 'credential', id
							Credential::Proxy.new connection, path, params
						end
					end

					module Credential
						class Proxy < ::Jenkins2::ResourceProxy
							# Deletes credential
							def delete
								connection.post( build_path 'doDelete' )
							end
						end
					end
				end
			end
		end
	end
end
