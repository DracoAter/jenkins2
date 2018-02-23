# frozen_string_literal: true

require_relative 'rud'

module Jenkins2
	class API
		# Allows manipulating jobs (projects). Supports cloudbees-folder plugin - i.e. nested jobs.
		module Job
			# Step into proxy for managing jobs.
			# ==== Parameters:
			# +name+:: Job name
			# +params+:: Key-value parameters. They will be added as URL parameters to request.
			# ==== Returns:
			# A Jenkins2::API::Job::Proxy object
			def job(name, **params)
				proxy = Proxy.new connection, 'job', params
				proxy.id = name
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id
				include ::Jenkins2::API::RUD

				# Create a new job from config.xml.
				# ==== Parameters:
				# +config_xml+:: config.xml of new job as string.
				# ==== Returns:
				# True on success
				def create(config_xml)
					path = ::File.join(::File.dirname(@path), 'createItem')
					connection.post(path, config_xml, name: id) do |req|
						req['Content-Type'] = 'text/xml'
					end.code == '200'
				end

				# Create a new job by copying another one.
				# ==== Parameters:
				# +from+:: Job name to copy new job from.
				# ==== Returns:
				# True on success.
				def copy(from)
					path = ::File.join(::File.dirname(@path), 'createItem')
					connection.post(path, nil, name: id, from: from, mode: 'copy').code == '302'
				end

				# Disable a job, restrict all builds of the job from now on.
				# ==== Returns:
				# True on success.
				def disable
					connection.post(build_path('disable')).code == '302'
				end

				# Enable job, allow building the job. Cancels previously issued "disable".
				# ==== Returns:
				# True on success.
				def enable
					connection.post(build_path('enable')).code == '302'
				end

				# Schedule a job build. Allows to pass build parameters, if required.
				# ==== Returns:
				# True on success.
				def build(build_parameters={})
					if build_parameters.empty?
						connection.post(build_path('build'))
					else
						connection.post(build_path('buildWithParameters'), nil, build_parameters)
					end.code == '201'
				end

				def polling
					connection.post(build_path('polling')).code == '302'
				end

				# cloudbees-folder plugin provides special type of job - folder. So now we can have
				# nested jobs. This methods allows to go 1 job deeper.
				# ==== Parameters:
				# +name+:: Job name
				# +params+:: Key-value parameters. They will be added as URL parameters to request.
				# ==== Returns:
				# A new Jenkins2::API::Job::Proxy object
				def job(name, **params)
					proxy = Proxy.new connection, build_path('job'), params
					proxy.id = name
					proxy
				end

				# cloudbees-folder plugin provides special type of job - folder. You can now create
				# credentials inside particular folder.
				# ==== Parameters:
				# +params+:: Key-value parameters. They will be added as URL parameters to request.
				# ==== Returns:
				# A new Jenkins2::API::Credentials::Proxy object
				def credentials(params={})
					::Jenkins2::API::Credentials::Proxy.new connection, build_path('credentials'), params
				end
			end
		end
	end
end
