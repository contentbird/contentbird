class SendEmail < JobBase
  acts_as_scalable

  @queue = :send_emails

  def self.retry_interval
    return 1
  end

  def self.do_perform mail_type, subject_class, subject_id, args = nil
    subject = nil

    2.times do
      subject = subject_class.constantize.find_by_id(subject_id)
      unless subject.nil?
        break
      end
      sleep(retry_interval)
    end

    if subject.nil?
      raise "Can not find #{subject_class} with id #{subject_id.to_s}"
    else
      if args
        UserMailer.send(mail_type, subject, args.symbolize_keys!).deliver
      else
        UserMailer.send(mail_type, subject).deliver
      end
    end
  end

end