FROM ppay_app_base

USER deploy

ARG RAILS_ENV
ARG BUNDLE_PATH

ENV RAILS_ENV="${RAILS_ENV}" \
    BUNDLE_PATH="${BUNDLE_PATH}"

COPY --chown=deploy:deploy Gemfile* ./
RUN bundle install --jobs "$(nproc)"

COPY --chown=deploy:deploy bin/ ./bin
RUN chmod 0755 bin/*

COPY --chown=deploy:deploy . .

USER root
RUN ruby env.rb >> $APP_USER_HOME/.profile
