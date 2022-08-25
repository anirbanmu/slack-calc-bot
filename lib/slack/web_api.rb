# frozen_string_literal: true

require 'uri'
require 'net/http'

module Slack
  # Namespace for the Slack WebAPI client
  module WebAPI
    BASE_SLACK_API_URL = URI('https://slack.com/api/')

    def self.post_message(bot_token, channel, message)
      Rails.logger.info 'Slack::WebAPI::post_message started'
      Rails.logger.info "  bot_token: #{bot_token}, channel: #{channel}, message: #{message}" if Rails.env.development?

      post_message_api_url = URI.join(BASE_SLACK_API_URL, 'chat.postMessage')

      request = build_post_request(bot_token, post_message_api_url)
      request.body = { channel: channel, text: message }.to_json
      response = Net::HTTP.start(post_message_api_url.hostname, post_message_api_url.port, use_ssl: true) do |http|
        http.request(request)
      end

      Rails.logger.info "  chat.postMessage returned #{response.code}"
      Rails.logger.info "  chat.postMessage returned with #{response.body}" if Rails.env.development?
      Rails.logger.info "Slack::WebAPI::post_message completed\n"

      response
    end

    def self.build_post_request(token, url)
      request = Net::HTTP::Post.new(url, Authorization: "Bearer #{token}")
      request.content_type = 'application/json; charset=utf-8'
      request
    end
  end
end
