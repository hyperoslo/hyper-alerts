class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    subscriptions = current_user.subscriptions

    @subscriptions = case params[:type]
    when "facebook"
      subscriptions.where subscribable_type: 'Services::Facebook::Page'
    when "twitter_search"
      subscriptions.where subscribable_type: 'Services::Twitter::Search'
    when "twitter_timeline"
      subscriptions.where subscribable_type: 'Services::Twitter::Timeline'
    else
      subscriptions
    end

    respond_to do |format|
    	format.html
    	format.json
    end
  end

  def show
    @subscription = current_user.subscriptions.find params[:id]

    respond_to do |format|
      format.json
    end
  end

  def create
    if params[:page]
      subscribable = Services::Facebook::Page.find_or_create_by facebook_id: params[:page][:facebook_id] do |s|
        s.name = params[:page][:name]

        s.synchronize current_user.facebook_access_token.token, only: [:likes]
      end
    elsif params[:search]
      subscribable = Services::Twitter::Search.find_or_create_by terms: params[:search][:terms]
    elsif params[:timeline]
      subscribable = Services::Twitter::Timeline.find_or_create_by twitter_id: params[:timeline][:twitter_id] do |s|
        s.screen_name = params[:timeline][:screen_name]
        s.picture_url = params[:timeline][:picture_url]
        s.name        = params[:timeline][:name]
      end
    end

    @subscription = Subscription.new do |s|
      s.user         = current_user
      s.preset       = params[:subscription][:preset]
      s.frequency    = params[:subscription][:frequency]
      s.polled       = params[:subscription][:polled]
      s.pushed       = params[:subscription][:pushed]
      s.scope        = params[:subscription][:scope]
      s.subscribable = subscribable
    end

    if @subscription.pushed?
      @subscription.subscribe_to_real_time_updates
    end

    respond_to do |format|
      if @subscription.save
        format.json { render template: "subscriptions/show", status: :created }
      else
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @subscription = current_user.subscriptions.find params[:id]

    respond_to do |format|
      @subscription.attributes = params[:subscription]

      if @subscription.pushed_changed?
        if @subscription.pushed?
          @subscription.subscribe_to_real_time_updates
        else
          @subscription.unsubscribe_from_real_time_updates
        end
      end

      if @subscription.save
        format.json { render template: "subscriptions/show", status: :ok }
      else
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subscription = current_user.subscriptions.find params[:id]
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_url }
      format.json { render nothing: true, status: :ok }
    end
  end
end
