# frozen_string_literal: true

require Rails.root.join('lib/slack/web_api')
require Rails.root.join('lib/infix_evaluator')

module Slack
  # Job that wraps calculating the arithmetic & sends response back to Slack
  class CalculateAndSendJob
    include SuckerPunch::Job

    def perform(text, user, channel, bot_token)
      message = "<@#{user}>"
      begin
        evaluator = InfixEvaluator.new(text)
        message += " #{evaluator.parsed_expression} = #{evaluator.result}"
      rescue ArgumentError
        message += ' I could not understand the arithmetic expression'
      end

      response = Slack::WebAPI.post_message(bot_token, channel, message)
      logger.warn "Slack::CalculateAndSendJob failed to send message with #{response.code} & body #{response.body}" if response.code != '200'
    end
  end
end
