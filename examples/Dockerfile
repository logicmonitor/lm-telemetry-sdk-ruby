# Sample docker file for build ECS image
FROM ruby:3.0
COPY ecs.rb test-ecs.rb Gemfile ./
RUN bundle install
CMD ["ruby","test.rb"]