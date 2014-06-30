class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :authenticate_user!, only: [:twitter]

  # Create and/or sign in a Facebook user.
  def facebook
    user = User.find_or_initialize_by provider: auth.provider, uid: auth.uid do |user|
      # We don't get an e-mail address from Facebook, so we can't very well confirm it.
      user.skip_confirmation!
    end

    if user.new_record?
      token = Services::Facebook::AccessToken.new do |token|
        token.user       = user
        token.token      = auth.credentials.token

        if auth.credentials.expires_at.nil?
          token.expires_at = nil
        else
          token.expires_at = Time.at auth.credentials.expires_at
        end
      end

      user.name = user.graph.name

      user.save
      token.save
    else
      user.facebook_access_token.renew auth.credentials.token, auth.credentials.expires_at
    end

    sign_in_and_redirect user, event: :authentication
  end

  # Authorize with Twitter and store the access token on the user
  def twitter
    user = current_user

    if user.twitter_access_token.present?
      user.twitter_access_token.renew auth.credentials.token, auth.credentials.secret
    else
      token = Services::Twitter::AccessToken.new do |token|
        token.user    = user
        token.token   = auth.credentials.token
        token.secret  = auth.credentials.secret
      end

      token.save!
    end

    redirect_to subscriptions_url
  end

  private

  def auth
    request.env["omniauth.auth"]
  end
end
