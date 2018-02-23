# frozen_string_literal: true

module Jenkins2
	class CLI
		# class Build < CLI
		# 	# TODO: implement
		# end

		class CopyJob < CLI
			def self.description
				'Copy a job.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-f', '--from NAME', 'Name of the job to copy from.' do |f|
					options[:from] = f
				end
				parser.on '-n', '--name NAME', 'Name of the new job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name from]
			end

			def run
				jc.job(options[:name]).copy(options[:from])
			end
		end

		class CreateJob < CLI
			def self.description
				'Create a new job by reading stdin as an XML configuration.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the new job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).create($stdin.read)
			end
		end

		class DeleteJob < CLI
			def self.description
				'Delete a job.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).delete
			end
		end

		class DisableJob < CLI
			def self.description
				'Disable a job, restrict all builds of the job from now on.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).disable
			end
		end

		class EnableJob < CLI
			def self.description
				'Enable job, allow building the job. Cancels previously issued "disable-job".'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).enable
			end
		end

		class GetJob < CLI
			def self.description
				'Dump the job definition XML to stdout.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).config_xml
			end
		end

		class ListJobs < CLI
			def self.description
				'List all jobs in a specific view or item group.'
			end

			private

			def add_options
				parser.separator 'Optional arguments:'
				parser.on '--view VIEW', 'Name of the view. Default - All.' do |v|
					options[:view] = v
				end
			end

			def run
				jc.view(options[:view] || 'All').jobs.collect(&:name).join("\n")
			end
		end

		class UpdateJob < CLI
			def self.description
				'Update the job definition XML from stdin. The opposite of the "get-job" command.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the job.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + %i[name]
			end

			def run
				jc.job(options[:name]).update($stdin.read)
			end
		end
	end
end
