# encoding: utf-8
module RegexHelper
	
	def short_name_from_name_regex
		/\A[a-z](?:-?[a-z0-9])+/i
	end

end
