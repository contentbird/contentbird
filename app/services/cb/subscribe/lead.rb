class CB::Subscribe::Lead

  def find token
    CB::Core::Lead.find_by_token(token)
  end

  def create email
    lead = CB::Core::Lead.create(email: email)
    [lead.persisted?, lead]
  end

  def invite lead
    lead.generate_token!
    JobRunner.run SendEmail, 'invite_lead', 'CB::Core::Lead', lead.id
  end

  def invite_all
    CB::Core::Lead.to_invite.each do |lead|
      begin
        invite lead
      rescue => e
        puts "Error while inviting lead with email #{lead.email}: #{e.message}"
      end
    end
  end

  def burn token
    lead = find(token)
    if lead
      lead.destroy
    else
      false
    end
  end

end