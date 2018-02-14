# frozen_string_literal: true

module Jenkins2
	class CLI
		class CreateCredentialsByXml < CLI
			def self.description
				'Create credential by reading stdin as an XML configuration.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
			end

			def mandatory_arguments
				super + %i[store domain]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).create($stdin.read)
			end
		end

		class CreateCredentialsDomainByXml < CLI
			def self.description
				'Create credential domain by reading stdin as an XML configuration.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
			end

			def mandatory_arguments
				super + %i[store]
			end

			def run
				jc.credentials.store(options[:store]).create_domain($stdin.read)
			end
		end

		class DeleteCredentials < CLI
			def self.description
				'Delete credentials.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
				parser.on '--credential ID', 'Credential id.' do |c|
					options[:credential] = c
				end
			end

			def mandatory_arguments
				super + %i[store domain credential]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).
					credential(options[:credential]).delete
			end
		end

		class DeleteCredentialsDomain < CLI
			def self.description
				'Delete credentials domain.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
			end

			def mandatory_arguments
				super + %i[store domain]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).delete
			end
		end

		class GetCredentialsAsXml < CLI
			def self.description
				'Get a credential as XML (secrets redacted).'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
				parser.on '--credential ID', 'Credential id.' do |c|
					options[:credential] = c
				end
			end

			def mandatory_arguments
				super + %i[store domain credential]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).
					credential(options[:credential]).config_xml
			end
		end

		class GetCredentialsDomainAsXml < CLI
			def self.description
				'Get credentials domain as XML.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
			end

			def mandatory_arguments
				super + %i[store domain]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).config_xml
			end
		end

		class ListCredentials < CLI
			def self.description
				'Lists credentials in a specific store.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
			end

			def mandatory_arguments
				super + [:store]
			end

			def run
				jc.credentials.store(options[:store], depth: 2).domains.to_h.collect do |_, v|
					"Domain: #{v.displayName}\n" +
						v.credentials.collect do |crd|
							"#{crd.id} - #{crd.displayName}"
						end.join("\n")
				end.join("\n")
			end
		end

		class UpdateCredentialsByXml < CLI
			def self.description
				'Update credentials by XML.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
				parser.on '--credential ID', 'Credential id.' do |c|
					options[:credential] = c
				end
			end

			def mandatory_arguments
				super + %i[store domain credential]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).
					credential(options[:credential]).update($stdin.read)
			end
		end

		class UpdateCredentialsDomainByXml < CLI
			def self.description
				'Update credentials domain by XML.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--store STORE', 'Store id. (e.g. "system")' do |s|
					options[:store] = s
				end
				parser.on '--domain DOMAIN', 'Domain id. (e.g. "_")' do |d|
					options[:domain] = d
				end
			end

			def mandatory_arguments
				super + %i[store domain]
			end

			def run
				jc.credentials.store(options[:store]).domain(options[:domain]).update($stdin.read)
			end
		end
	end
end
