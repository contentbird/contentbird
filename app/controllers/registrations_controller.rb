class RegistrationsController < Devise::RegistrationsController
  layout 'public', only: [:new, :create]
  before_action {section 'account'}
  def new
    @lead = CB::Subscribe::Lead.new.find(params[:token]) if params[:token].present?
    unless REGISTRATION_ACTIVE || @lead
      redirect_to new_lead_path
      return
    end
    build_resource({})
    if @lead
      resource.token = @lead.token
      resource.email = @lead.email
    end
    respond_with self.resource
  end

  def create
    super
    if resource.persisted?
      CB::Subscribe::Lead.new.burn(resource.token) if resource.token.present?
      account_builder = CB::Build::Account.new(resource)
      account_builder.set_default_content_types_usages
      account_builder.create_default_website if resource.advanced?
    end
  end

  def destroy
    JobRunner.run(DeleteUser, resource.id)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  def after_sign_up_path_for resource
    new_user_setup_path
  end

  def after_update_path_for resource
    dashboard_path
  end

end
