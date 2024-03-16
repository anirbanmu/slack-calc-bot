# frozen_string_literal: true

describe Slack::CalculateAndSendJob do
  describe '#perform' do
    let(:slack_bot_access_token) { SecureRandom.hex }
    let(:event) { { text: '1+2', channel: SecureRandom.hex, user: SecureRandom.hex } }

    it 'calls postMessage' do
      allow(Slack::WebApi).to receive(:post_message).and_return(double(code: '200')) # rubocop:disable RSpec/VerifiedDoubles
      described_class.perform_async(event[:text], event[:user], event[:channel], slack_bot_access_token)
      expect(Slack::WebApi).to have_received(:post_message).once.with(slack_bot_access_token, event[:channel], String)
    end
  end
end
