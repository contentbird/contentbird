class CB::Build::Account
  attr_reader :user

  def initialize user
    @user = user
  end

  def set_default_content_types_usages
    CB::Core::ContentType.usable_by_default.each do |type|
      type.add_usage_for_user(user)
    end
  end

  def create_default_website
    channel = user.channels.build url_prefix: user.nest_name, name: 'My website'
    channel.save_with_new_url_prefix
  end

end