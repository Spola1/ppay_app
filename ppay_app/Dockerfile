# Dockerfile Rails

FROM ruby:3.1.2-slim-bullseye AS assets

WORKDIR /app

ARG UID=1000
ARG GID=1000


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
  && mkdir /node_modules && chown deploy:deploy -R /node_modules /app"

USER deploy

COPY --chown=deploy:deploy Gemfile* ./
RUN bundle install --jobs "$(nproc)"

COPY --chown=deploy:deploy bin/ ./bin
RUN chmod 0755 bin/*

# COPY --chown=deploy:deploy package.json *yarn* ./
# RUN yarn install

ARG RAILS_ENV="production"
ARG NODE_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/home/deploy/.local/bin:/node_modules/.bin" \
    USER="deploy"

COPY --chown=deploy:deploy . .

RUN chmod +x entrypoint-rails.sh
ENTRYPOINT ["./entrypoint-rails.sh"]

EXPOSE 3000

# CMD ["rails", "s", "-b", "0.0.0.0", "-p", "3000"]

