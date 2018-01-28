require 'slack/calculate_and_send_job'

describe Slack::CalculateAndSendJob do
  describe '#perform' do
    let(:slack_bot_access_token) { SecureRandom.hex }
    let(:event) { { channel: SecureRandom.hex, user: SecureRandom.hex } }
    it 'calls postMessage' do
      expect(Slack::WebAPI).to receive(:post_message).with(slack_bot_access_token, event[:channel], String).and_return( double(code: '200') )
      Slack::CalculateAndSendJob.perform_async(event, slack_bot_access_token)
    end
  end
end
