class CB::Build::GoogleplusChannel < CB::Build::BaseChannel
  def user_name
    oauth[:info][:name]
  end

  def name_prefix
    "+"
  end

  def url_prefix
    "gp-"
  end

  def secret
    oauth[:credentials][:refresh_token]
  end
end