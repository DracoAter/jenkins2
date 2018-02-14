# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CliCredentialsTest < Minitest::Test
			def test_create_credentials_by_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-credentials-by-xml        Create credential by reading stdin as an XML configuration.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
), Jenkins2::CLI::CreateCredentialsByXml.new.send(:summary)
			end

			def test_create_credentials_domain_by_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-credentials-domain-by-xml Create credential domain by reading stdin as an XML \
configuration.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
), Jenkins2::CLI::CreateCredentialsDomainByXml.new.send(:summary)
			end

			def test_delete_credentials_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    delete-credentials               Delete credentials.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
        --credential ID              Credential id.
), Jenkins2::CLI::DeleteCredentials.new.send(:summary)
			end

			def test_delete_credentials_domain_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    delete-credentials-domain        Delete credentials domain.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
), Jenkins2::CLI::DeleteCredentialsDomain.new.send(:summary)
			end

			def test_get_credentials_as_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    get-credentials-as-xml           Get a credential as XML (secrets redacted).
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
        --credential ID              Credential id.
), Jenkins2::CLI::GetCredentialsAsXml.new.send(:summary)
			end

			def test_get_credentials_domain_as_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    get-credentials-domain-as-xml    Get credentials domain as XML.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
), Jenkins2::CLI::GetCredentialsDomainAsXml.new.send(:summary)
			end

			def test_list_credentials_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    list-credentials                 Lists credentials in a specific store.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
), Jenkins2::CLI::ListCredentials.new.send(:summary)
			end

			def test_update_credentials_by_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    update-credentials-by-xml        Update credentials by XML.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
        --credential ID              Credential id.
), Jenkins2::CLI::UpdateCredentialsByXml.new.send(:summary)
			end

			def test_update_credentials_domain_by_xml_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    update-credentials-domain-by-xml Update credentials domain by XML.
Mandatory arguments:
        --store STORE                Store id. (e.g. "system")
        --domain DOMAIN              Domain id. (e.g. "_")
), Jenkins2::CLI::UpdateCredentialsDomainByXml.new.send(:summary)
			end
		end
	end
end
