module BaseFilter
  def should_filter?(target)
    return false if target.nil?
    return true if @filter_empty && target.strip.empty?

    @action == (@matcher.matches?(target) ? :blacklist : :whitelist)
  end
end
