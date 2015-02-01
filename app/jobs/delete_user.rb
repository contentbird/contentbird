class DeleteUser < JobBase

  acts_as_scalable scale_down: false

  @queue = :delete_user

  def self.do_perform user_id
    user = CB::Core::User.find user_id
    service = CB::Manage::Content.new(user)

    content_ids_array = []
    user.content_types.each do |content_type|
      a = service.recent_for_type(content_type).pluck(:id)
      (content_ids_array << a) if a.any?
    end

    if user.destroy
      content_ids_array.each do |content_ids|
        JobRunner.run(DeleteContentsImages, user.id, content_ids)
      end
    else
      raise "Could not destroy user #{user.id}"
    end

  end
end