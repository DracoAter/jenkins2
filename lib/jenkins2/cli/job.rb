module Jenkins2
	class CLI
		class ListJobs < CLI
			def self.description
				'Lists all jobs in a specific view or item group.'
			end

			def add_options
				parser.separator 'Optional arguments:'
				parser.on '-n', '--name NAME', 'Name of the view. Default - all' do |n|
					options[:name] = n
				end
			end

			def run
			end
		end

		class CopyJob < CLI
			def self.description
				'Copies a job.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-f', '--from NAME', 'Name of the job to copy.' do |f|
					options[:from] = f
				end
				parser.on '-n', '--name NAME', 'Name of the new job, to be created.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.job( options[:name] ).copy( options[:from] )
			end
		end
	end
end
