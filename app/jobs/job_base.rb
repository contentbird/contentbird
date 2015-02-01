class JobBase
  include Scalable

  def self.perform locale, *args
    I18n.with_locale locale do
      do_perform *args
    end
  end

  def self.do_perform
    #must be implemented in every concrete job class
  end

end