# Sample docker file for build ECS image
FROM ruby:3.0
COPY test_ecs.rb Gemfile ./
RUN bundle install
CMD ["ruby","test_ecs.rb"]