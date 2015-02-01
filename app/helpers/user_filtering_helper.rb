module UserFilteringHelper

  def restrict_access
    if ip_filter_activated? && !user_ip_allowed?
      ENV['MAINTENANCE_PAGE_URL'].present? ? redirect_to(ENV['MAINTENANCE_PAGE_URL']) : render(text: "IP #{user_ip} Not authorized")
      return
    end
  end

private
  def remote_ip?
    user_ip != "127.0.0.1"
  end

  def user_ip
    request.remote_ip
  end

  def ip_filter_activated?
    IP_FILTERING
  end

  def user_ip_allowed?
    user_ip.present? && IP_WHITELIST.keys.include?(user_ip)
  end
end