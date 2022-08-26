FROM docker.io/library/ruby:3.1.2-alpine
LABEL Author="Anirban Mukhopadhyay"

RUN apk update && apk upgrade && apk add tzdata

ARG USER=ruby-user

# Create a non-root user
RUN addgroup -S ${USER} && adduser -D -H -S -G ${USER} ${USER}

COPY --chown=${USER}:${USER} config.ru Gemfile Gemfile.lock Rakefile entrypoint.sh /src/
COPY --chown=${USER}:${USER} app/ /src/app/
COPY --chown=${USER}:${USER} bin/ /src/bin/
COPY --chown=${USER}:${USER} config/ /src/config/
COPY --chown=${USER}:${USER} lib/ /src/lib/

WORKDIR /src

ENV BUNDLE_WITHOUT "development:test"
RUN apk update \
    && apk add --virtual build-dependencies build-base \
    && gem install bundler -v $(tail -n1 Gemfile.lock | tr -d ' ') \
    && bundle \
    && apk del build-dependencies

USER ${USER}

ENV PORT 8080
ENTRYPOINT ["./entrypoint.sh"]
