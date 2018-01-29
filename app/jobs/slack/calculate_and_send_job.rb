require "#{Rails.root}/lib/slack/web_api"
require "#{Rails.root}/lib/infix_evaluator"

class Slack::CalculateAndSendJob
  include SuckerPunch::Job

  def perform(text, user, channel, bot_token)
    message = "<@#{user}>"
    begin
      evaluator = InfixEvaluator.new(text)
      message = message + " #{evaluator.parsed_expression} = #{evaluator.result}"
    rescue ArgumentError
      message = message + ' I could not understand the arithmetic expression'
    end

    response = Slack::WebAPI.post_message(bot_token, channel, message)
    if response.code != '200'
      logger.warn "Slack::CalculateAndSendJob failed to send message with #{response.code} & body #{response.body}"
    end
  end
end
