module Jenkins2
	class CLI
		class InstallPlugin < CLI
			def self.description
				'Installs a plugin'
			end

			def add_options
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
			end

			def run
				jc.plugins.install options[:name]
			end
		end

		class UninstallPlugin < CLI
			def self.description
				'Uninstalls a plugin'
			end

			def add_options
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
			end

			def run
				jc.plugins.plugin( options[:name] ).uninstall
			end
		end

		class ShowPlugin < CLI
			def self.description
				'Show plugin info'
			end

			def add_options
				parser.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |n|
					options[:name] = n
				end
			end

			def run
				jc.plugins.plugin( options[:name] ).subject
			end
		end
	end
end
