
# Monkey patching some utility methods in timetwister to add more things to
# match on when setting certainty to 'approximate'

class Utilities

  APPROX_VALUES = AppConfig.has_key?(:tns_timewalk_approximate_forms) ? AppConfig[:tns_timewalk_approximate_forms] :
                    ['ca', 'circa', 'approx', 'approximate', 'before', 'after', 'probably', 'prob', 'between']

  # match values capitalized or not and with an optional trailing dot
  # we don't have control over how it's used so can't just assert a case-insensitive match
  APPROX_REGEX = '((' + APPROX_VALUES.map{|v| [v.capitalize + '\.?', v + '\.?']}.flatten.join(')|(') + '))'


  unless self.methods.include?(:regex_tokens_pre_tns)
    class << self
      alias_method(:regex_tokens_pre_tns, :regex_tokens)
    end
  end


  def self.regex_tokens
    tokens = regex_tokens_pre_tns

    # was:
    # '\s*[Cc](irc)?a?\.?\s*'
    # which might be a bug because it wasn't matching 'approx'

    tokens[:circa] = '\s*' + APPROX_REGEX + '\s*'
    tokens
  end


  # copying whole method instead of aliasing
	def self.return_certainty(str)
		# order of precedence, from least to most certain:
    # 1) questionable dates
    # 2) approximate dates
    # 3) inferred dates

    if str.include?('?')
      return 'questionable'
    end

    # was:
    # if str.downcase.include?('ca') || \
    #   str.downcase.include?('approx')
    #   return 'approximate'
    # end

    if str.match(APPROX_REGEX)
      return 'approximate'
    end

    if str.include?('[') || str.include?(']')
      return 'inferred'
    end

    return nil
	end

end
