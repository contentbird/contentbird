class InviteAllLeads
  def self.do_perform
    CB::Subscribe::Lead.new.invite_all
  end
end