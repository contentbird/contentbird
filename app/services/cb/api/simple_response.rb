class CB::Api::SimpleResponse
  def initialize channel, result, params={}
    @channel = channel
    @response = {result: result}
    add_context_to_response(params[:context].split(',')) if params[:context].present?
  end

  def response_headers
    {}
  end

  def response_body
    @response
  end

private

  def add_context_to_response context
    context.each do |c|
      @response[c.to_sym] = self.send "#{c}_context"
    end
  end

  def sections_context
    CB::Query::Section.new(@channel).list
  end

  def channel_context
    @channel
  end

  def html_context
    CB::Util::Renderer.render_template('contents/_form', {content: @response[:result]})[/<!-- begin_cut_zone -->(.*)<!-- end_cut_zone -->/m, 1]
  end

end