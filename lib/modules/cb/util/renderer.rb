module CB::Util::Renderer
  def self.render_template template, params
    CB::Util::ApiView.new('app/views', params).render(file: "api/#{template}")
  end
end

class CB::Util::ApiView < ActionView::Base
  def protect_against_forgery?
    false
  end
end
