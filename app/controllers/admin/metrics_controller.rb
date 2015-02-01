class Admin::MetricsController < Admin::BaseController
  def index
    @user_count                   = CB::Core::User.count
    @contents_count               = CB::Core::Content.joins(:content_type).group('content_types.name').count
    @publications_count           = CB::Core::Publication.count
    @deleted_publications_count   = CB::Core::Publication.unscoped.where.not(deleted_at: nil).count
    @expiring_publications_count  = CB::Core::Publication.where.not(expire_at: nil).count
  end
end