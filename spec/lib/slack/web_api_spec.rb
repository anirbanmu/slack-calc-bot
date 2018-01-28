require 'slack/web_api'

describe Slack::WebAPI do
  describe '.post_message' do
    let(:slack_bot_access_token) { SecureRandom.hex }
    let(:channel) { SecureRandom.hex }
    let(:message) { Faker::Lorem.sentence }
    it 'calls chat.postMessage Slack API with correct parameters' do
      stub_request(:post, "https://slack.com/api/chat.postMessage").
        with(body: "{\"channel\":\"#{channel}\",\"text\":\"#{message}\"}",
             headers: { 'Authorization': "Bearer #{slack_bot_access_token}", 'Content-Type': 'application/json; charset=utf-8', 'Host': 'slack.com' } ).
        to_return(status: 200, body: "", headers: {})

      expect(Slack::WebAPI::post_message(slack_bot_access_token, channel, message).code).to eq('200')
    end
  end
end
