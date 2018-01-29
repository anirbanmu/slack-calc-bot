# slack-calc-bot
Bot for Slack that evaluates arithmetic expressions

## Setup
### On Slack side
- Create a new application at https://api.slack.com/apps
- After the application is created, head to the application settings & create an associated bot user (click on 'Bot Users' in the left hand menu under 'Features')
- Note down the 'Verification Token' given on the 'Basic Information' page for the application (should be of form `https://api.slack.com/apps/<some-app-id>/general?`)
- Install application to your workspace & note down the `Bot User OAuth Access Token` on the 'Installed App Settings' page for the app (should be of form `https://api.slack.com/apps/<some-app-id>/install-on-team?`)

### On your machine/server
- Install Ruby.
- Install Bundler - `gem install bundler`
- Clone this repo
- If you'd like to use Heroku to run the bot, skip the next 3 steps and jump down to 'Heroku Setup'
- From the repo directory, run `bundle install`
- Set two environment variables as follows from the Slack information we noted down earlier:
   - SLACK_APP_TOKEN=<Verification Token noted down from the 'Basic Information' page on Slack>
   - SLACK_BOT_ACCESS_TOKEN=<Bot User OAuth Access Token noted down from the 'Installed App Settings' page on Slack>
- Run the Rails application via `rails server`

### Heroku setup
- This assumes you have the heroku toolbelt installed on your machine & are set up with credentials for Heroku. Check here if you need to set it up - [Heroku](https://devcenter.heroku.com/articles/heroku-cli).
- From the repo directory, run `heroku create`
- Run `heroku config:set SLACK_APP_TOKEN=<Verification Token noted down from the 'Basic Information' page on Slack>`
- Run `heroku config:set SLACK_BOT_ACCESS_TOKEN=<Bot User OAuth Access Token noted down from the 'Installed App Settings' page on Slack>`
- Push the repo to Heroku via `git push heroku master`
- You should see that Heroku successfully deploys your bot

### Back on Slack
- Navigate to the 'Event Subscriptions' page for your app (should be of form `https://api.slack.com/apps/<some-app-id>/event-subscriptions?`)
- Enable events
- For 'Request URL' enter the URL/IP of the machine you're hosting the bot on followed by `slack/events/receive` (should be of the form `https://my.sub.domain.com/slack/events/receive`)
- As long as you did the previous block properly on your machine/server, the verification should be successful.
- Scroll down to 'Subscribe to Bot Events' & subscribe to these two events:
  - `app_mention`
  - `message.im`
- Save changes.

You're all set to start messaging the app/bot. Invite the bot to your channel & highlight it with arithmetic expressions. Direct messages to the application also work.

## Tests
This assumes you've completed the `On your machine/server` section above. To execute tests run `bundle exec rspec`.
