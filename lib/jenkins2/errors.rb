module Jenkins2
	class NoValidCrumbError < StandardError
		def self.===( exception )
			exception.message == '403 "No valid crumb was included in the request"'
		end
	end

	class NotFoundError < StandardError
		def self.===( exception )
			exception.message == '404 "Not Found"'
		end
	end

	class ServiceUnavalableError < StandardError
		def self.===( exception )
			exception.message == '503 "Service Unavailable"'
		end
	end
end
