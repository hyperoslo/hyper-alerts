class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :save_invitation
  around_filter :user_time_zone, if: :current_user

  def after_sign_in_path_for resource
    root_url
  end

  private

  # Validate and cache the invitation to a cookie.
  #
  # This cookie is later read by the OmniAuth callbacks controller to verify
  # that the user is in fact permitted to register.
  def save_invitation
    key       = params[:key]
    signature = params[:signature]
    cookie    = cookies[:invitation]

    if key && signature
      invitation = Invitation.new key: key

      if signature == invitation.signature
        if invitation.save
          cookies[:invitation] = invitation.id
        else
          flash[:alert] = invitation.errors.full_messages.first
        end
      else
        flash[:alert] = "Invalid signature"
      end
    end unless cookie
  end

  # Configure time for the user's time zone.
  def user_time_zone &block
    Time.use_zone current_user.time_zone, &block
  end
end
