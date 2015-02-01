class Admin::BaseController < ApplicationController
  before_action :admin_only!
  layout 'admin'

private

def admin_only!
  unless current_user.present? && current_user.respond_to?(:admin?) && current_user.admin?
    raise ActionController::RoutingError.new('Not Found')
  end
end

end