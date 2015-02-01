class Admin::UsersController < Admin::BaseController

  def index
  	@users = CB::Core::User.order('id DESC').page(params[:page]).per(20)
  end

  def become
    user = CB::Core::User.find(params[:id])
    return redirect_to(:back, alert: 'You can not become a power user') if (user.admin? || user.platform_user?)
    sign_in(:user, CB::Core::User.find(params[:id]), bypass: true)
    session[:become_user] = true
  end

  def show
    @user                  = CB::Core::User.find params[:id]
    @last_content_time     = @user.contents.order('id DESC').first.try(:created_at)
    @last_publication_time = CB::Core::Publication.unscoped.owned_by(@user).recent.first.try(:published_at)
    @channels              = @user.channels
    @types_summary         = ActiveRecord::Base.connection.execute(%Q{SELECT SUM("contents"."publications_count") AS publications_count,
                                                                            COUNT(*) as contents_count,
                                                                            content_types.name AS content_type_name
                                                                      FROM "contents"
                                                                      INNER JOIN "content_types" ON "content_types"."id" = "contents"."content_type_id"
                                                                      WHERE "contents"."owner_id" = #{@user.id}
                                                                      GROUP BY content_types.name}).to_a
    attributes = @user.attributes.reject{ |k,v| ['encrypted_password', 'reset_password_token'].include? k }.to_a
    batch_size = (attributes.size / 2).to_i
    @left_attributes = attributes.first(batch_size)
    @right_attributes = attributes.last(attributes.size - batch_size)
  end

end