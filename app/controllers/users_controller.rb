class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user
  before_filter :require_self, only: [:edit, :update, :time_zone_difference, :destroy]

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    respond_to do |format|
      @user.email          = params[:user][:email]
      @user.time_zone_name = params[:user][:time_zone_name]

      @user.skip_reconfirmation! if params[:user][:email].blank?

      if @user.save
        format.html { redirect_to edit_user_url(@user), notice: "Settings updated" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @user.destroy

    redirect_to :root
  end

  def migrate
    legacy = Legacy.new params[:email], params[:password]

    respond_to do |format|

      begin
        subscriptions = legacy.subscriptions
      rescue Legacy::Error => error
        format.html { redirect_to :back, alert: error.message }
      else
        subscriptions.map do |subscription|
          # Ignore pages that the user already subscribes to.
          next if current_user.subscribes_to? subscription.subscribable

          subscription.user = current_user
          subscription.save!
        end

        legacy.disable

        @subscriptions = subscriptions

        format.html
      end
    end
  end

  def time_zone_difference
    time_zone_name = params[:time_zone_name]

    current_time_zone = ActiveSupport::TimeZone[time_zone_name]

    if current_time_zone
      difference_in_hours = (current_time_zone.utc_offset - @user.time_zone.utc_offset) / 60 / 60

      render text: difference_in_hours
    else
      render text: "Unsupported time zone", status: :bad_request
    end
  end

  private

  def get_user
    id = params[:id]

    if id == "me"
      @user = current_user
    else
      @user = User.find params[:id]
    end
  end

  def require_self
    unless @user == current_user
      render text: "Forbidden", status: :forbidden
    end
  end
end
