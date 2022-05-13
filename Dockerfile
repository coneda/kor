FROM ruby:2.7.5

ADD . /opt/kor
WORKDIR /opt/kor

RUN \
  apt-get update && \
  apt-get install -y ffmpeg

RUN bundle config set --local clean 'true'
RUN bundle config set --local path '/opt/bundle'
RUN bundle config set --local without 'development:test'
RUN bundle install

# Install dependencies, build the frontend and remove the dependencies. We do
# this so that the image size stays small
RUN \
  apt-get install -y nodejs npm rsync && \
  npm install && \
  npm run build && \
  rm -rf ./node_modules && \
  apt-get purge -y nodejs npm rsync && \
  apt-get autoremove -y

ENTRYPOINT ["deploy/entrypoint.sh"]
