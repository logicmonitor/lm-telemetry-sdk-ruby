#!/bin/bash -e

# cleanup
rm -rf vendor/bundle

echo "Preparing build dir..."
mkdir -p vendor/bundle/ruby/lib
mkdir -p vendor/bundle/ruby/gems

echo "Installing dependencies..."
bundle install --path=vendor/bundle

echo "Coping gems to layer structure..."
mv -f vendor/bundle/ruby/2.7.0 vendor/bundle/ruby/gems/ && cp -r cached-gems/2.7.0 vendor/bundle/ruby/gems/

echo "Optimizing size..."
rm -rf vendor/bundle/ruby/gems/2.7.0/cache
rm -rf vendor/bundle/ruby/gems/2.7.0/gems/google-protobuf-3.19.4-x86_64-darwin
rm -rf vendor/bundle/ruby/gems/2.7.0/specifications/google-protobuf-3.19.4-x86_64-darwin.gemspec

echo "Packaging dependencies into zip archive..."
cd vendor/bundle
zip -qr9 ruby.zip *