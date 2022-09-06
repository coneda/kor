FROM ruby:2.7.5

RUN \
  apt-get update && \
  apt-get install -y ffmpeg nodejs npm rsync default-mysql-client

ADD . /opt/kor
WORKDIR /opt/kor

RUN npm install

# windows compat
ARG MYWINDIR
ENV MYWINDIR $MYWINDIR
RUN widgets/build.sh replace_symlinks

RUN npm run build
RUN rm -rf ./node_modules

# Remove the dependencies. We do this so that the image size stays small
# RUN apt-get purge -y nodejs npm rsync
# RUN apt-get autoremove -y

RUN bundle config set --local clean 'true'
RUN bundle config set --local path '/opt/bundle'
RUN bundle config set --local without 'development:test'
RUN bundle install

ENTRYPOINT ["deploy/entrypoint.sh"]
