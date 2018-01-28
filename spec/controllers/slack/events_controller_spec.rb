require 'rails_helper'

describe Slack::EventsController do
  before(:all) do
    Rails.application.secrets.slack_app_token = SecureRandom.hex
  end

  let(:slack_app_token) { Rails.application.secrets.slack_app_token }
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
      it 'responds with success' do
        post :receive, params: { type: 'event_callback', token: slack_app_token }
        expect(response).to be_success
      end
    end
  end

  private

  def json_body
    JSON.parse(response.body)
  end
end
