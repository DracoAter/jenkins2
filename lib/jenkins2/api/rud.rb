# frozen_string_literal: true

module Jenkins2
	class API
		module RUD
			# = Read
			def config_xml
				connection.get(build_path('config.xml')).body
			end

			def update(config_xml)
				connection.post(build_path('config.xml'), config_xml).code == '200'
			end

			def delete
				connection.post(build_path('doDelete')).code == '302'
				# connection.delete(build_path('config.xml')).code == '302'
			end
		end
	end
end
