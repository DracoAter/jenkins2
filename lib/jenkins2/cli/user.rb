# frozen_string_literal: true

module Jenkins2
	class CLI
		class WhoAmI < CLI
			def self.description
				'Report your credentials.'
			end

			def run
				r = jc.me.subject
				%w[id fullName description].collect{|p| "#{p}: #{r[p]}" }.join "\n"
			end
		end
	end
end
