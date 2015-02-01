namespace :cb do
  desc "Invite all non invited Leads to register on CB"
  task invite_leads: :environment do
    InviteAllLeads.do_perform
  end
end