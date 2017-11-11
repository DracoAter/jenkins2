module Jenkins2
	class CLI
		class WhoAmI < CLI
			def self.description
				'Reports your credentials.'
			end

			def run
				jc.me
			end
		end
	end
end
