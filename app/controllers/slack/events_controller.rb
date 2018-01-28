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
      Slack::CalculateAndSendJob.perform_async(event, Rails.application.secrets.slack_bot_access_token) if event[:subtype] != 'bot_message'
    end

    head :ok
  end
end
