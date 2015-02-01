namespace :cb do
  desc "Unpublish all expired publications"
  task expire_publications: :environment do
    DeleteExpiredPublications.do_perform
  end
end