require 'rails_helper'

describe Slack::EventsController do
  before(:all) do
    Rails.application.secrets.slack_app_token = SecureRandom.hex
    Rails.application.secrets.slack_bot_access_token = SecureRandom.hex
  end

  let(:slack_app_token) { Rails.application.secrets.slack_app_token }
  let(:slack_bot_access_token) { Rails.application.secrets.slack_bot_access_token }

  describe '#receive' do
    context 'base parameter validation' do
      it 'responds with 400 when no token' do
        post :receive
        expect(response.code).to eq('400')
      end

      it 'responds with 400 when token is invalid' do
        post :receive, params: { token: slack_app_token + '1' }
        expect(response.code).to eq('400')
      end

      it 'responds with success when token is valid' do
        post :receive, params: { token: slack_app_token }
        expect(response).to be_success
      end
    end

    context 'url_verification' do
      it 'responds with given challenge' do
        challenge = SecureRandom.hex
        post :receive, params: { type: 'url_verification', challenge: challenge, token: slack_app_token }
        expect(response).to be_success
        expect(json_body).to eq({ 'challenge' => challenge })
      end
    end

    context 'event_callback' do
      it 'responds with success when type is not of interest' do
        expect(Slack::CalculateAndSendJob).to_not receive(:perform_async)
        post :receive, params: { type: 'event_callback', token: slack_app_token, event: { type: nil } }
        expect(response).to be_success
      end

      context "type is 'message'" do
        it 'responds with success & enqueues CalculateAndSendJob' do
          event = { 'type' => 'message', 'text' => Faker::Lorem.word, 'user' => Faker::Lorem.word, 'channel' => Faker::Lorem.word }
          expect(Slack::CalculateAndSendJob).to receive(:perform_async).with(event['text'], event['user'], event['channel'], slack_bot_access_token)
          post :receive, params: { type: 'event_callback', token: slack_app_token, event: event }
          expect(response).to be_success
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when subtype is 'bot_message'" do
          expect(Slack::CalculateAndSendJob).to_not receive(:perform_async)
          post :receive, params: { type: 'event_callback', token: slack_app_token, event: { type: 'message', subtype: 'bot_message' } }
          expect(response).to be_success
        end
      end

      context "type is 'app_mention'" do
        it 'responds with success & enqueues CalculateAndSendJob' do
          event = { 'type' => 'app_mention', 'text' => Faker::Lorem.word, 'user' => Faker::Lorem.word, 'channel' => Faker::Lorem.word }
          expect(Slack::CalculateAndSendJob).to receive(:perform_async).with(event['text'], event['user'], event['channel'], slack_bot_access_token)
          post :receive, params: { type: 'event_callback', token: slack_app_token, event: event }
          expect(response).to be_success
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when subtype is 'bot_message'" do
          expect(Slack::CalculateAndSendJob).to_not receive(:perform_async)
          post :receive, params: { type: 'event_callback', token: slack_app_token, event: { type: 'app_mention', subtype: 'bot_message' } }
          expect(response).to be_success
        end
      end
    end
  end

  private

  def json_body
    JSON.parse(response.body)
  end
end
