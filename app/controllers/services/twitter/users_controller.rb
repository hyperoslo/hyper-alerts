class Services::Twitter::UsersController < ApplicationController
  respond_to :json

  # Proxy for Twitter search API endpoint
  def search
    token = current_user.twitter_access_token
    client = Twitter::Client.new oauth_token: token.token, oauth_token_secret: token.secret

    @users = client.user_search params['q'], {
      count: params['count']
    }

    respond_with @users
  end
end
