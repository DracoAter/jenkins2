module Jenkins2
	class CLI
		class AddJobToView < CLI
			def self.description
				'Adds jobs to view.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
				parser.on '-j', '--job X,Y,..', Array, 'Job name(s) to add.' do |j|
					options[:job] = j
				end
			end

			def run
				options[:job].all? do |job|
					jc.view( options[:name] ).add_job( job )
				end
			end
		end

		class CreateView < CLI
			def self.description
				'Creates a new view by reading stdin as a XML configuration.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.view( options[:name] ).create( $stdin.read )
			end
		end

		class DeleteView < CLI
			def self.description
				'Delete view(s).'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name X,Y,..', Array, 'View names to delete.' do |n|
					options[:name] = n
				end
			end

			def run
				options[:name].all? do |name|
					jc.view( options[:name] ).delete
				end
			end
		end

		class GetView < CLI
			def self.description
				'Dumps the view definition XML to stdout.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.view( options[:name] ).config_xml
			end
		end

		class RemoveJobFromView < CLI
			def self.description
				'Removes jobs from view.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
				parser.on '-j', '--job X,Y,..', Array, 'Job name(s) to remove.' do |j|
					options[:job] = j
				end
			end

			def run
				options[:job].all? do |job|
					jc.view( options[:name] ).remove_job( job )
				end
			end
		end

		class UpdateView < CLI
			def self.description
				'Updates the view definition XML from stdin. The opposite of the get-view command.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.view( options[:name] ).update( $stdin.read )
			end
		end
	end
end
