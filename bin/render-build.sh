#!/usr/bin/env bash
# exit on error
set -o errexit
set -o pipefail

bundle install
yarn install
yarn build:css
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
