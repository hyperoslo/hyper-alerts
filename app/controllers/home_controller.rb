class HomeController < ApplicationController
  def index
  	redirect_to subscriptions_url if user_signed_in?
  end
end
