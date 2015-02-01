class CB::Build::DeveloperChannel < CB::Build::BaseChannel
  def name_prefix
    "dev-"
  end

  def url_prefix
    "dev-"
  end
end