module Jenkins2
	module URI
		PATH = "a-zA-Z0-9\\-\\.\\_\\~\\!\\?\\$\\&\\'\\(\\)\\*\\+\\,\\;\\=\\:\\@\\/"
		def self.escape( s )
			s.gsub( /[^#{PATH}]/ ) do |char|
				char.unpack( 'C*' ).map{|c| ("%%%02x" % c).upcase }.join
			end
		end
	end
end
