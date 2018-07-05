# Count
# Returns the instances of specified characters
# {{ content | count: "content-card" }}

module Find

  def find(haystack, needle)

    haystack = haystack.to_s
    needle   = needle.to_s

    if (haystack.nil? or haystack.empty?) or (needle.nil? or needle.empty?)
      return
    end

    haystack.scan(needle).count

  end

end

Liquid::Template.register_filter(Find)