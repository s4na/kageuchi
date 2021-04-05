FROM ruby:2.7.2

WORKDIR /app
RUN apt-get update && apt-get install -y

ADD ./* $HOME/
ADD ./bin/setup $HOME/bin/
ADD ./bin/test $HOME/bin/

EXPOSE 1234
