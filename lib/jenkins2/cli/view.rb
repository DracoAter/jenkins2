# frozen_string_literal: true

module Jenkins2
	class CLI
		class CreateView < CLI
			def self.description
				'Create a new view by reading stdin as an XML configuration.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				jc.view(options[:name]).create($stdin.read)
			end
		end

		class DeleteView < CLI
			def self.description
				'Delete view(s).'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name X,Y,..', Array, 'View names to delete.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				options[:name].all? do |name|
					jc.view(name).delete
				end
			end
		end

		class GetView < CLI
			def self.description
				'Dump the view definition XML to stdout.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				jc.view(options[:name]).config_xml
			end
		end

		class UpdateView < CLI
			def self.description
				'Update the view definition XML from stdin. The opposite of the get-view command.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				jc.view(options[:name]).update($stdin.read)
			end
		end

		class AddJobToView < CLI
			def self.description
				'Add jobs to view.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
				parser.on '-j', '--job X,Y,..', Array, 'Job name(s) to add.' do |j|
					options[:job] = j
				end
			end

			def mandatory_arguments
				super + %i[name job]
			end

			def run
				options[:job].all? do |job|
					jc.view(options[:name]).add_job(job)
				end
			end
		end

		class RemoveJobFromView < CLI
			def self.description
				'Remove jobs from view.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the view.' do |n|
					options[:name] = n
				end
				parser.on '-j', '--job X,Y,..', Array, 'Job name(s) to remove.' do |j|
					options[:job] = j
				end
			end

			def mandatory_arguments
				super + %i[name job]
			end

			def run
				options[:job].all? do |job|
					jc.view(options[:name]).remove_job(job)
				end
			end
		end
	end
end
