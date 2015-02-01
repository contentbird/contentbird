require 'spec_helper'
require 'rake'

describe "invite leads rake task" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load "#{Rails.root}/lib/tasks/invite_leads.rake"
    Rake::Task.define_task(:environment)
    @task_name = "cb:invite_leads"
  end

  it "run InviteAllLeads job" do
    InviteAllLeads.should_receive(:do_perform)

    @rake[@task_name].invoke
  end
end