class CB::Manage::MessagingChannel < CB::Manage::Channel

  def build_new params={}
    CB::Core::MessagingChannel.new params
  end

  def find key
    CB::Core::MessagingChannel.owned_by(user).includes(subscriptions: :contact).find(key)
  end

end