require File.expand_path(File.dirname(__FILE__) + '/../../spec/support/spec_utils.rb')

Around '@needs_job' do |scenario, block|
  with_constants(:JOBS_RUN => true) {block.call}
end