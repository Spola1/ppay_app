FROM ruby:3.1.2

# ENV APP_ENV_RB ./esokolov_app_rails/env.rb
# ENV OUTSIDE_APP_REPO_DIR ./esokolov_app_rails/esokolov_app
# ENV ENTRYPOINT_FILE ./ppay_app/rails-entrypoint.sh
ENV ENTRYPOINT_FILE sidekiq-entrypoint.sh

# делаю апдейты и ставим необходимый софт
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# ставим crontab, для работы whenever
RUN apt-get install -y cron

# Use a directory called /code in which to store
# this application's files. (The directory name
# is arbitrary and could have been anything.)
WORKDIR /code

# Copy all the application's files into the /code
# directory.
# COPY $OUTSIDE_APP_REPO_DIR /code
# COPY ./ppay_app .
COPY --from=cloud.canister.io:5000/ffyy289/ppay_app:latest code .

# Подготовим скрипт - скопируем его в папку
# COPY $ENTRYPOINT_FILE /usr/bin/
# RUN chmod +x /usr/bin/rails-entrypoint.sh
COPY $ENTRYPOINT_FILE sidekiq-entrypoint.sh

# Run bundle install to install the Ruby dependencies.
# RUN bundle install
RUN bundle check || bundle install

# Install Yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Run yarn install to install JavaScript dependencies.
RUN yarn install --check-files


RUN chmod +x sidekiq-entrypoint.sh

# Стартуем при каждом запуске контейнера
ENTRYPOINT ["./sidekiq-entrypoint.sh"]
