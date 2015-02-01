class CB::Manage::Channel
  require 'cb/core/channel'

  attr_reader :user

  def initialize user
    @user = user
  end

  def list
    user.channels
  end

  def find key
    list.find(key)
  end

  def build_new params={}
    CB::Core::Channel.new params
  end

  def create params
    channel       = build_new(params)
    channel.owner = user
    result        = channel.save
    [result, channel]
  end

  def update key, params
    chan   = find(key)
    result = chan.update_attributes(params)
    [result, chan]
  end

  def destroy key
    channel = find(key)
    result  = channel.destroy
    [result, channel]
  end

  def reset_access_token key
    channel = find(key)
    channel.generate_access_token
    result  = channel.save
    [result, channel.access_token]
  end

  def openit key
    update key, closed_at: nil
  end

  def closeit key
    update key, closed_at: Time.now
  end

end