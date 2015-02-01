class HomeController < ApplicationController
  layout 'public'
  before_action :force_no_ssl

  def index
    render "index", layout: 'home'
  end

  def styleguide
  end

  def about
    render "home/about/#{I18n.locale}"
  end

  def privacy
    render "home/privacy/#{I18n.locale}"
  end

  def terms
    render "home/terms/#{I18n.locale}"
  end

end