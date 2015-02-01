class CleanSocialPublications < JobBase

  acts_as_scalable scale_down: false

  @queue = :clean_social_publications

  def self.do_perform publications
  	publications.each { |publication| JobRunner.run(CleanSocialPublication, publication[0], publication[1]) }
  end

end