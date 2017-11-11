module Jenkins2
	class BadRequestError < Net::HTTPError
		def initialize( res )
			if res.body.nil? or res.body.empty?
				super( '', res )
			else
				super( res.body.match( '<h1>Error</h1><p>(.*)</p>' )[1], res )
			end
		end
	end

	class NotFoundError < Net::HTTPError
		def initialize( res )
			super( res.body.match( '<h2>HTTP ERROR 404</h2>\n<p>(.*) Reason:' )[1], res )
		end
	end

	class ServiceUnavailableError < Net::HTTPError
		def initialize( res )
			if res.body.nil? or res.body.empty?
				super( '', res )
			else
				super( res.body.match( '<h1[^>]*>\n\s+([^<]+)' )[1], res )
			end
		end
	end

	class NoValidCrumbMatcher
		def self.===( exception )
			exception.message == '403 "No valid crumb was included in the request"'
		end
	end
end
