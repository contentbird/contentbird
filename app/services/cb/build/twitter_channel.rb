class CB::Build::TwitterChannel < CB::Build::BaseChannel
  def name_prefix
    "@"
  end

  def url_prefix
    "at-"
  end
end