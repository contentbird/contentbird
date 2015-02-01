class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || version_in_headers?(req)
  end

private
  def version_in_headers? req
    req.headers['Accept'] && req.headers['Accept'].include?("application/vnd.contentbird.v#{@version}")
  end
end