# Dockerfile Rails

FROM ruby:3.1.2-bullseye

WORKDIR /app

ARG UID=1000
ARG GID=1000

ARG RAILS_ENV
ARG BUNDLE_PATH

ENV RAILS_ENV="${RAILS_ENV}" \
    BUNDLE_PATH="${BUNDLE_PATH}" \
    PATH="${PATH}:/home/deploy/.local/bin:/node_modules/.bin" \
    USER="deploy"

RUN bash -c "set -o pipefail && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev cron \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g \"${GID}\" deploy \
  && useradd --create-home --no-log-init -u \"${UID}\" -g \"${GID}\" deploy \
  && mkdir -p /bundle && chown deploy:deploy -R /app /bundle"

USER deploy

ENV APP_USER_HOME /home/deploy

COPY --chown=deploy:deploy Gemfile* ./
RUN bundle install --jobs "$(nproc)"

COPY --chown=deploy:deploy bin/ ./bin
RUN chmod 0755 bin/*

COPY --chown=deploy:deploy . .

USER root
RUN ruby env.rb >> $APP_USER_HOME/.profile
