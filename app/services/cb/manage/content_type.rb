class CB::Manage::ContentType

  attr_reader :user

  def initialize user
    @user = user
  end

  def build_forked_type content_type
    forked_type = content_type.dup
    content_type.properties.each do |property|
      forked_type.properties << property.dup
    end
    forked_type.owner             = user
    forked_type.origin_type       = content_type
    forked_type.usable_by_default = false
    forked_type.by_platform       = user.platform_user
    forked_type
  end

  def fork_type content_type
    forked_type = build_forked_type content_type
    forked_type.save!
    forked_type
  end

  def user_made_types
    CB::Core::ContentType.owned_by(user)
  end

  def user_types
    user.content_types
  end

  def selectable_types
    CB::Core::ContentType.basic
  end

  def build_new params={}
    CB::Core::ContentType.new params
  end

  def find key
    user_types.find(key)
  end

  def find_own key
    user_made_types.find(key)
  end

  def update key, params
    type   = find_own(key)
    result = type.update_attributes(params)
    JobRunner.run(PropagatePropertiesChanges, type.id) if (result && type.contents_count > 0)
    [result, type]
  end

  def create params
    type             = build_new(params)
    type.owner       = user
    type.by_platform = user.platform_user

    result = type.save
    [result, type]
  end

  def destroy key
    type        = find_own(key)
    content_ids = type.content_ids
    destroyed   = type.destroy
    JobRunner.run(DeleteContentsImages, user.id, content_ids) if destroyed
    [destroyed, type]
  end
end