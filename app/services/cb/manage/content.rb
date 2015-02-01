class CB::Manage::Content

  attr_reader :user

  def initialize user
    @user = user
  end

  def build_new content_type, params={}
  	CB::Core::Content.new({owner: user, content_type: content_type}.merge(params))
  end

  def create content_type, params={}
    content = build_new(content_type, params)
    created = content.save
    [created, content]
  end

  def recent_for_type content_type
    CB::Core::Content.owned_by(user).of_type(content_type).recent
  end

  def recent
    CB::Core::Content.owned_by(user).includes(:content_type).recent
  end

  def find key
    CB::Core::Content.owned_by(user).find(key)
  end

  def update key, params
    content = find(key)
    updated = content.update_attributes(params)
    [updated, content]
  end

  def destroy key
    content    = find(key)
    cleanable_publications_ids = content.active_social_publications.map{|pub| [pub.channel_id, pub.provider_ref]}
    destroyed  = content.destroy
    if destroyed
      JobRunner.run(DeleteContentsImages,    user.id, [content.id])
      JobRunner.run(CleanSocialPublications, cleanable_publications_ids)
    end
    [destroyed, content]
  end

end