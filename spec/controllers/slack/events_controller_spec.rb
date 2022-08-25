# frozen_string_literal: true

require 'rails_helper'

describe Slack::EventsController do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Rails.application.secrets.slack_signing_secret = SecureRandom.hex
    Rails.application.secrets.slack_bot_access_token = SecureRandom.hex
  end

  let(:slack_signing_secret) { Rails.application.secrets.slack_signing_secret }
  let(:slack_bot_access_token) { Rails.application.secrets.slack_bot_access_token }

  let(:timestamp) { Time.now.to_i.to_s }

  def calculate_and_set_valid_headers(body = '')
    hashed = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      slack_signing_secret,
      "v0:#{timestamp}:#{body}"
    )

    request.headers['X-Slack-Request-Timestamp'] = timestamp
    request.headers['X-Slack-Signature'] = "v0=#{hashed}"
  end

  describe '#receive' do
    context 'base signature validation' do
      it 'responds with 400 when no signature' do
        post :receive
        expect(response.code).to eq('400')
      end

      it 'responds with 400 when signature is invalid' do
        request.headers['X-Slack-Request-Timestamp'] = timestamp
        request.headers['X-Slack-Signature'] = 'invalid'
        post :receive
        expect(response.code).to eq('400')
      end

      it 'responds with success when signature is valid' do
        calculate_and_set_valid_headers
        post :receive
        expect(response).to be_successful
      end
    end

    context 'url_verification' do
      it 'responds with given challenge' do
        challenge = SecureRandom.hex
        body = { type: 'url_verification', challenge: challenge }.to_json
        calculate_and_set_valid_headers(body)
        post :receive, body: body, as: :json

        expect(response).to be_successful
        expect(json_body).to eq({ 'challenge' => challenge })
      end
    end

    context 'event_callback' do
      before { calculate_and_set_valid_headers }

      it 'responds with success when type is not of interest' do
        allow(Slack::CalculateAndSendJob).to receive(:perform_async)

        body = { type: 'event_callback', event: { type: 'something' } }.to_json
        calculate_and_set_valid_headers(body)
        post :receive, body: body, as: :json

        expect(response).to be_successful
        expect(Slack::CalculateAndSendJob).not_to have_received(:perform_async)
      end

      context "type is 'message'" do
        it 'responds with success & enqueues CalculateAndSendJob' do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          event = { 'type' => 'message', 'text' => Faker::Lorem.word, 'user' => Faker::Lorem.word,
                    'channel' => Faker::Lorem.word }
          body = { type: 'event_callback', event: event }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).to have_received(:perform_async).with(
            event['text'],
            event['user'],
            event['channel'],
            slack_bot_access_token
          ).once
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when app_id is present" do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          body = { type: 'event_callback', event: { type: 'message', app_id: 'app_id' } }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).not_to have_received(:perform_async)
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when bot_profile is present" do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          body = { type: 'event_callback', event: { type: 'message', bot_profile: {} } }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).not_to have_received(:perform_async)
        end
      end

      context "type is 'app_mention'" do
        it 'responds with success & enqueues CalculateAndSendJob' do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          event = { 'type' => 'app_mention', 'text' => Faker::Lorem.word, 'user' => Faker::Lorem.word,
                    'channel' => Faker::Lorem.word }
          body = { type: 'event_callback', event: event }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).to have_received(:perform_async).with(
            event['text'],
            event['user'],
            event['channel'],
            slack_bot_access_token
          ).once
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when app_id is present" do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          body = { type: 'event_callback', event: { type: 'app_mention', app_id: 'app_id' } }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).not_to have_received(:perform_async)
        end

        it "responds with success & doesn't enqueue CalculateAndSendJob when bot_profile is present" do
          allow(Slack::CalculateAndSendJob).to receive(:perform_async)

          body = { type: 'event_callback', event: { type: 'app_mention', bot_profile: {} } }.to_json
          calculate_and_set_valid_headers(body)
          post :receive, body: body, as: :json

          expect(response).to be_successful
          expect(Slack::CalculateAndSendJob).not_to have_received(:perform_async)
        end
      end
    end
  end

  private

  def json_body
    JSON.parse(response.body)
  end
end
