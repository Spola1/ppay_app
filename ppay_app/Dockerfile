FROM ubuntu:22.04
RUN echo "Ubuntu release:"
RUN cat /etc/os-release

USER root

RUN apt-get update -qq && apt-get install -y \
 curl

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update -qq && apt-get install -y \
 software-properties-common \
 build-essential \
 libpq-dev \
 libxml2-dev \
 libxslt1-dev \
 libyaml-dev \
 libreadline6-dev \
 zlib1g-dev \
 libssl1.1-dev \
 nodejs \
 imagemagick \
 apt-transport-https \
 nano \
 sudo \
 libsqlite3-dev \
 git

RUN npm install --global yarn
RUN yarn --version

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata

RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-install-suggests curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L https://github.com/rbenv/ruby-build/archive/v20221004.tar.gz | tar -zxvf - -C /tmp/ && \
  cd /tmp/ruby-build-* && ./install.sh && cd / && \
  ruby-build -v 3.1.2 /usr/local && rm -rfv /tmp/ruby-build-* && \
  gem install bundler -v 2.3.24

# переменная для docker composer - APP_NAME

# Layer 3. Создаем переменные окружения которые буду дальше использовать в Dockerfile
ENV APP_USER deploy
ENV APP_USER_HOME /home/$APP_USER
ENV APP_HOME /var/www/ppay_app

# Layer 4. Поскольку по умолчанию Docker запускаем контейнер от имени root пользователя, то настоятельно рекомендуется создать отдельного пользователя c определенными UID и GID и запустить процесс от имени этого пользователя.
RUN useradd -m -d $APP_USER_HOME $APP_USER

# Layer 5. Даем root пользователем пользователю deploy права owner'а на необходимые директории
RUN mkdir /var/www && \
 chown -R $APP_USER:$APP_USER /var/www && \
 chown -R $APP_USER $APP_USER_HOME

# Layer 6. Создаем и указываем директорию в которую будет помещено приложение. Так же теперь команды RUN, ENTRYPOINT, CMD будут запускаться с этой директории.
WORKDIR $APP_HOME

# Layer 7. Указываем все команды, которые будут выполняться от имени app пользователя
USER $APP_USER

# Layer 8. Добавляем файлы Gemfile и Gemfile.lock из директории, где лежит Dockerfile (root директория приложения на HostOS) в root директорию WORKDIR
COPY Gemfile Gemfile.lock ./

USER root
RUN gem install rjb -v '1.6.1' --source 'https://rubygems.org/'
USER $APP_USER

USER root

# Layer 9. Вызываем команду по установке gem-зависимостей. Рекомендуется запускать эту команду от имени пользователя от которого будет запускаться само приложение
RUN bundle check || bundle install

# Layer 10. Копируем все содержимое директории приложения в root-директорию WORKDIR
COPY . .

# Layer 11. Указываем все команды, которые будут выполняться от имени root пользователя
USER root

# Layer 12. Даем root пользователем пользователю deploy права owner'а на WORKDIR
RUN chown -R $APP_USER:$APP_USER "$APP_HOME/."

# Layer 13. Указываем все команды, которые будут выполняться от имени deploy пользователя
USER $APP_USER

RUN yarn --update-checksums
RUN yarn install --check-files

# Layer 14. Запускаем команду для компиляции статических (JS и CSS) файлов
# RUN bin/rails assets:precompile


# Layer 15. Указываем команду по умолчанию для запуска будущего контейнера. По скольку в `Layer 13` мы переопределили пользователя, то puma сервер будет запущен от имени www-data пользователя.
# CMD bundle exec puma -C config/puma.rb

USER root

RUN ruby ./env.rb >> $APP_USER_HOME/.profile


ENTRYPOINT ["./rails-entrypoint.sh"]


