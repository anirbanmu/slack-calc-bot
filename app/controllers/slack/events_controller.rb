class Slack::EventsController < ApplicationController
  before_action :validate_params

  def receive
    case params[:type]
    when 'url_verification'
      handle_url_verification params[:challenge]
    when 'event_callback'
      handle_event_callback params[:event]
    end
  end

  private

  # Trust call if app token is valid
  def validate_params
    head :bad_request if params[:token] != Rails.application.secrets.slack_app_token
  end

  def handle_url_verification(challenge)
    render json: { challenge: challenge }
  end

  def handle_event_callback(event)
    case event[:type]
    when 'message', 'app_mention'
      if event[:subtype] != 'bot_message'
        Slack::CalculateAndSendJob.perform_async(message_text(event), message_user(event), event[:channel], Rails.application.secrets.slack_bot_access_token)
      end
    end

    head :ok
  end

  def message_user(event)
    event[:user] ? event[:user] : event[:message][:user]
  end

  def message_text(event)
    event[:text] ? event[:text] : event[:message][:text]
  end
end
