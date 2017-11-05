require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiJobTest < Minitest::Test
			CONFIG_XML = '<project><builders/><publishers/><buildWrappers/></project>'

			NEW_CONFIG_XML = '<project><disabled>true</disabled><builders/><publishers/><buildWrappers/></project>'

			def setup
				@@subj.job( 'xml config' ).create( CONFIG_XML )
				@@subj.job( 'for deletion' ).create( CONFIG_XML )
			end
			
			def teardown
				@@subj.job( 'new one' ).delete rescue nil
				@@subj.job( 'for deletion' ).delete rescue nil
				@@subj.job( 'xml config' ).delete
			end

			def test_create
				assert @@subj.job( 'new one' ).create( CONFIG_XML )
				assert_equal 'new one', @@subj.job( 'new one' ).name
			end

			def test_job
				exc = assert_raises Net::HTTPServerException do
					@@subj.job( 'nonexistent' ).subject
				end
				assert_equal '404 "Not Found"', exc.message
			end

			def test_update_config_xml
				assert CONFIG_XML, @@subj.job( 'xml config' ).config_xml
				assert @@subj.job( 'xml config' ).update( NEW_CONFIG_XML )
				assert NEW_CONFIG_XML, @@subj.job( 'xml config' ).config_xml
			end

			def test_delete
				assert_equal 'for deletion', @@subj.job( 'for deletion' ).name
				@@subj.job( 'for deletion' ).delete
			end

			def test_enable_disable
				assert @@subj.job( 'xml config' ).disable
				refute @@subj.job( 'xml config' ).buildable
				assert @@subj.job( 'xml config' ).enable
				assert @@subj.job( 'xml config' ).buildable
			end
		end
	end
end

