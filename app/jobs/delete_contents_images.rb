class DeleteContentsImages < JobBase
  acts_as_scalable

  @queue = :delete_contents_images

  def self.do_perform user_id, content_ids=[]
    storage = Storage.new(:content_image)
    content_ids.each do |content_id|
      storage.delete_all_starting_with_path "#{user_id}/#{content_id}/"
    end
  end
end