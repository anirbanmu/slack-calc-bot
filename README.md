# slack-calc-bot
Bot for Slack that evaluates arithmetic expressions. Supports addition (`+`), subtraction (`-`), multiplication (`*`, `×`), division (`\`, `÷`), exponentiation (`^`) (use exponentiation for square roots & other roots) & parenthesis (`(`, `)`).

## Setup
These steps jump between local machine, Slack side & fly.io a lot, so please bear with me.

### On your machine
- Install Ruby.
- Install Bundler - `gem install bundler`
- Clone this repo
- (Optional) If you'd like to host the bot on [fly.io](https://fly.io/)
  - Install `flyctl` (instructions [here](https://fly.io/docs/getting-started/installing-flyctl/)).
  - Auth `flyctl`
  - From the repo directory, run `flyctl apps create` & choose options as prompted.
  - Note down the the app name you chose here, referred to as `<FLY-IO-APP-NAME>`.
  - Fill in this name `<FLY-IO-APP-NAME>` in [fly.toml](fly.toml) where it says `<FLY-IO-APP-NAME>`.
  - Go to `https://fly.io/apps/<FLY-IO-APP-NAME>` & note down it's hostname, will be referred to as `<FLY-IO-APP-URL>`.

### On Slack side
- Create a new application at https://api.slack.com/apps using the template manifest @ [slack-manifest.yml](slack-manifest.yml) filling in the following details:
  - `<URL-TO-YOUR-APP>`: can be either ngrok URL for development or `<FLY-IO-APP-URL>` if you're hosting on fly.io.
- Note down the 'Signing Secret' given on the 'Basic Information' page for the application (should be of form `https://api.slack.com/apps/<some-app-id>/general?`)
- Install application to your workspace & note down the `Bot User OAuth Token` on the 'Install App' page for the app (should be of form `https://api.slack.com/apps/<some-app-id>/install-on-team?`)

### Back on your machine (for local development)
- From the repo directory, run `bundle install`
- Set two environment variables as follows from the Slack information we noted down earlier:
   - SLACK_SIGNING_SECRET=<Signing Secret noted down from the 'Basic Information' page on Slack>
   - SLACK_BOT_ACCESS_TOKEN=<Bot User OAuth Token noted down from the 'Install App' page on Slack>
- Run the Rails application via `bundle exec rails server`

### Back on your machine (for fly.io deployment)
- Run `flyctl secrets set SLACK_SIGNING_SECRET=<Signing Secret noted down from the 'Basic Information' page on Slack>`
- Run `flyctl secrets set SLACK_BOT_ACCESS_TOKEN=<Bot User OAuth Token noted down from the 'Install App' page on Slack>`
- Run `bundle exec rails secret` & copy the value that's printed.
- Run `flyctl secrets set SECRET_KEY_BASE=<value copied in last step>`
- Run `flyctl deploy` to deploy
- You should see that fly.io successfully deploys your bot

### Back on Slack
- Navigate to the 'App Manfiest' page for your app (should be of form `https://app.slack.com/app-settings/<some-id>/<some-id>/app-manifest`)
- You'll see a message at the top regarding your request URL not being verified, go ahead and verify the URL. As long as you did the previous block properly on your machine/server, the verification should be successful.

You're all set to start messaging the app/bot. Invite the bot to your channel & highlight it with arithmetic expressions. Direct messages to the application also work.

## Tests
This assumes you've completed the `On your machine` & `Back on your machine (for local development)` section above. To execute tests run `bundle exec rspec`.

## Main source code locations
- Slack::EventsController - implements endpoint for Events API [`app/controllers/slack`](https://github.com/anirbanmu/slack-calc-bot/tree/master/app/controllers/slack)
- Slack::WebAPI - Wrapper to call Slack WebAPI [`lib/slack`](https://github.com/anirbanmu/slack-calc-bot/tree/master/lib/slack)
- InfixEvaluator - Class to parse and evaluate infix arithmetic [`lib`](https://github.com/anirbanmu/slack-calc-bot/tree/master/lib)
- Slack::CalculateAndSendJob - Async job to do infix evaluation & sending of slack message [`app/jobs/slack`](https://github.com/anirbanmu/slack-calc-bot/tree/master/app/jobs/slack)
- Test specs - RSpec tests [`spec`](https://github.com/anirbanmu/slack-calc-bot/tree/master/spec)
