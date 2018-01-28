require "#{Rails.root}/lib/slack/web_api"

class Slack::CalcMessageJob
  include SuckerPunch::Job

  def perform(message_event, bot_token)
    message = "<@#{message_event[:user]}> I see your message"
    response = Slack::WebAPI.post_message(bot_token, message_event[:channel], message)
    if response.code != '200'
      logger.warn "Slack::CalcMessageJob failed to send message with #{response.code} & body #{response.body}"
    end
  end
end
