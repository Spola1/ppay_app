FROM ruby:3.1.2

# ENV APP_ENV_RB ./esokolov_app_rails/env.rb
# ENV OUTSIDE_APP_REPO_DIR ./esokolov_app_rails/esokolov_app
# ENV ENTRYPOINT_FILE ./ppay_app/rails-entrypoint.sh
ENV ENTRYPOINT_FILE rails-entrypoint.sh

# делаю апдейты и ставим необходимый софт
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs


WORKDIR /code

# Copy all the application's files into the /code
COPY . /code

COPY $ENTRYPOINT_FILE rails-entrypoint.sh

RUN bundle check || bundle install

# Install Yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn
RUN yarn install --check-files


# CMD ["rails", "server", "-b", "0.0.0.0"]

RUN chmod +x rails-entrypoint.sh
ENTRYPOINT ["./rails-entrypoint.sh"]
# EXPOSE 3000
