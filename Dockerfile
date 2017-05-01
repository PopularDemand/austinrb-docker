FROM ruby:2.3.3
RUN gem install rack
RUN gem install puma
RUN gem install redis
RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
EXPOSE 80
CMD ["rackup","-s","puma","-o","0.0.0.0","-p","80"]
