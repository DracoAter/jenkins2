module Jenkins2
	class CLI
		class WhoAmI < CLI
			def self.description
				'Reports your credentials.'
			end

			def run
				r = jc.me.subject
				%w{id fullName description}.collect{|p| "#{p}: #{r[p]}" }.join "\n"
			end
		end
	end
end
