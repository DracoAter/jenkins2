require 'open-uri'

module Jenkins2
	class CLI
		class InstallPlugin < CLI
			def self.description
				'Installs a plugin either from a file, an URL, standard input or from update center.'
			end

			private

			def add_options
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
				parser.on '--source URI', 'If this points to a local file, it will be '\
				'installed. If this is an URL, the file will be downloaded and installed. If it '\
				'the "-" sting, the file will be read from standard input and "--name" must be '\
				'specified.' do |s|
					options[:source] = s
				end
			end

			def run
				case options[:source]
				when nil, ''
					jc.plugins.install options[:name]
				when '-'
					jc.plugins.upload( ARGF.read, options[:name] )
				else
					open( options[:source], 'rb' ) do |f|
						jc.plugins.upload( f.read, options[:name] || File.basename( options[:name] ) )
					end
				end
			end
		end

		class ListPlugins < CLI
			def self.description
				'Lists all installed plugins.'
			end

			private

			def run
				jc.plugins( depth: 1 ).plugins.collect do |pl|
					"%s (%s)" % [pl.shortName, pl.version]
				end.join("\n")
			end
		end

		class UninstallPlugin < CLI
			def self.description
				'Uninstalls a plugin.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				jc.plugins.plugin( options[:name] ).uninstall
			end
		end

		class ShowPlugin < CLI
			def self.description
				'Show plugin info.'
			end

			private

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
			end

			def mandatory_arguments
				super + [:name]
			end

			def run
				pl = jc.plugins.plugin( options[:name] ).subject
				"%s (%s) - %s" % [pl.shortName, pl.version, pl.longName]
			end
		end
	end
end
