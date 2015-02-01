class CB::Manage::APIChannel < CB::Manage::Channel

  def build_new params={}
    CB::Core::APIChannel.new params
  end

end