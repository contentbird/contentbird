class CB::Api::PaginatedResponse < CB::Api::SimpleResponse
  def initialize channel, result, params
    super
    paginate params[:page], params[:per]
  end

  def response_headers
    { 'pagination-current' => @response[:meta][:current_page],
      'pagination-last'    => @response[:meta][:total_pages] }
  end

  def paginate page=1, per
    per = 20 if per.try(:>, 20)
    paginated_result = per ? @response[:result].page(page).per(per) : @response[:result].page(page)
    @response[:meta] = {  current_page: paginated_result.current_page,
                          total_pages: paginated_result.total_pages }
    @response[:result] = paginated_result
  end
end