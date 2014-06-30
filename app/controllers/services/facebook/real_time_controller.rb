# Services::Facebook::RealTimeController handles requests from Facebook's Realtime updates:
#
# https://developers.facebook.com/docs/reference/api/realtime/
class Services::Facebook::RealTimeController < ApplicationController
  def verify
    verify_token = params["hub.verify_token"]
    challenge    = params["hub.challenge"]

    if verify_token and challenge
      if verify_token == Rails.configuration.facebook_real_time_updates_verify_token
        render text: params["hub.challenge"]
      else
        render text: "Invalid 'hub.verify_token'", status: :forbidden
      end
    else
      render text: "Missing required parameters 'hub.verify_token' and 'hub.challenge'", status: :bad_request
    end
  end

  def push
    entries = params[:entry]

    entries.each do |entry|
      # Ignore real time notifications for anything other than new posts and comments.
      next if entry[:changes].none? { |change| change[:value][:item] =~ /^(post|comment)$/ && change[:value][:verb] == "add" }

      page = Services::Facebook::Page.find_by facebook_id: entry[:id]

      page.subscriptions.pushed.each do |subscription|
        subscription.schedule
      end
    end

    render nothing: true
  end
end
