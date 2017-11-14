module Jenkins2
	class CLI
		class SafeRestart < CLI
			def self.description
				'Safely restart Jenkins.'
			end

			private

			def run
				jc.restart
			end
		end

		class Restart < CLI
			def self.description
				'Restart Jenkins.'
			end
			
			private

			def run
				jc.restart!
			end
		end

		class QuietDown < CLI
			def self.description
				'Put Jenkins into the quiet mode, wait for existing builds to be completed.'
			end
			
			private

			def run
				jc.quiet_down
			end
		end

		class CancelQuietDown < CLI
			def self.description
				'Cancel previously issued quiet-down command.'
			end
			
			private

			def run
				jc.cancel_quiet_down
			end
		end

		class Version < CLI
			def self.description
				'Jenkins version.'
			end
			
			private

			def run
				jc.version
			end
		end
	end
end
