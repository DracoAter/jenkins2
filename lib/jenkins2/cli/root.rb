module Jenkins2
	class CLI
		class Restart < CLI
			def self.description
				'Restart Jenkins'
			end
			
			def run
				jc.restart!
			end
		end

		class QuietDown < CLI
			def self.description
				'Put Jenkins into the quiet mode, wait for existing builds to be completed.'
			end
			
			def run
				jc.quiet_down
			end
		end

		class CancelQuietDown < CLI
			def self.description
				'Cancel previously issued quiet-down command'
			end
			
			def run
				jc.cancel_quiet_down
			end
		end

		class Me < CLI
			def self.description
				'Authenticated user info'
			end
			
			def run
				jc.me
			end
		end

		class Version < CLI
			def self.description
				'Jenkins version'
			end
			
			def run
				jc.version
			end
		end
	end
end
