module JobRunner
  def self.run job, *args
    protect_and_perform_if_synchrone(nil, job, *args) do |delay, job, args_with_locale|
      Resque.enqueue job, *args_with_locale
    end
  end

  def self.run_in delay, job, *args
    protect_and_perform_if_synchrone(delay, job, *args) do |delay, job, args_with_locale|
      Resque.enqueue_in delay, job, *args_with_locale
    end
  end

  private

  def self.can_run?
    JOBS_RUN
  end

  def self.synchronous?
    JOBS_SYNCHRONOUS
  end

  def self.protect_and_perform_if_synchrone delay, job, *args, &block
    if can_run?
      if synchronous?
        job.perform(I18n.locale, *args)
      else
        args_with_locale = [I18n.locale] + args
        yield(delay, job, args_with_locale)
      end
    end
    return true
  end
end