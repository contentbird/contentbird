class DeleteExpiredPublications < JobBase
  def self.do_perform
    publications = CB::Core::Publication.expired_to_delete

    publications.each do |publication|
      CB::Manage::Publication.new(publication.user).unpublish(publication)
    end
  end

  def test_floobit
    puts "floobit"
  end
end