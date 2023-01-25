# Dockerfile Rails

FROM ruby:3.1.2-slim-bullseye AS assets

WORKDIR /app

ARG UID=1000
ARG GID=1000

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    PATH="${PATH}:/home/deploy/.local/bin:/node_modules/.bin" \
    USER="deploy" \
    BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle \
    GEM_PATH=/bundle

RUN bash -c "set -o pipefail && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev \
  && curl -sSL https://deb.nodesource.com/setup_18.x | bash - \
  && curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g \"${GID}\" deploy \
  && useradd --create-home --no-log-init -u \"${UID}\" -g \"${GID}\" deploy \
  && mkdir /node_modules /bundle && chown deploy:deploy -R /node_modules /app /bundle"

# run cron as non root user
RUN chmod gu+rw /var/run

USER deploy

ENV APP_USER_HOME /home/deploy

COPY --chown=deploy:deploy Gemfile* ./
RUN bundle install --jobs "$(nproc)"

COPY --chown=deploy:deploy bin/ ./bin
RUN chmod 0755 bin/*

# COPY --chown=deploy:deploy package.json *yarn* ./
# RUN yarn install

COPY --chown=deploy:deploy . .

#RUN chmod +x entrypoint-rails.sh
#ENTRYPOINT ["./entrypoint-rails.sh"]

USER root
RUN ruby env.rb >> $APP_USER_HOME/.profile


# EXPOSE 3000

# CMD ["rails", "s", "-b", "0.0.0.0", "-p", "3000"]

