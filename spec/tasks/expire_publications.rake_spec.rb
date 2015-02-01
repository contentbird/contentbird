require 'spec_helper'
require 'rake'

describe "delete expired publications rake task" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load "#{Rails.root}/lib/tasks/expire_publications.rake"
    Rake::Task.define_task(:environment)
    @task_name = "cb:expire_publications"
  end

  it "run DeleteExpiredPublication job" do
    DeleteExpiredPublications.should_receive(:do_perform)

    @rake[@task_name].invoke
  end
end