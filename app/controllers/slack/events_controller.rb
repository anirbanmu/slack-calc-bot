# frozen_string_literal: true

module Slack
  # Deals with all events from Slack
  class EventsController < ApplicationController
    before_action :validate_request

    def receive
      case params[:type]
      when 'url_verification'
        handle_url_verification params[:challenge]
      when 'event_callback'
        handle_event_callback params[:event]
      end
    end

    private

    # Validate that this request is from Slack
    def validate_request
      hashed = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        Rails.application.credentials.slack.signing_secret,
        "v0:#{request.headers['X-Slack-Request-Timestamp']}:#{request.body.read}"
      )
      calculated_signature = "v0=#{hashed}"
      head :bad_request unless request.headers['X-Slack-Signature'] == calculated_signature
    end

    def handle_url_verification(challenge)
      render json: { challenge: }
    end

    def handle_event_callback(event)
      case event[:type]
      when 'message', 'app_mention'
        # Only post if it's not a bot message (AKA from us)
        if event[:app_id].nil? && event[:bot_profile].nil?
          Slack::CalculateAndSendJob.perform_async(message_text(event), message_user(event), event[:channel],
                                                   Rails.application.credentials.slack.bot_access_token)
        end
      end

      head :ok
    end

    def message_user(event)
      event[:user] || event[:message][:user]
    end

    def message_text(event)
      event[:text] || event[:message][:text]
    end
  end
end
