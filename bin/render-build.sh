#!/usr/bin/env bash
# exit on error
set -o errexit
set -o pipefail

export RAILS_ENV=production

bundle install
bundle exec rails assets:precompile || {
  echo "Asset precompilation failed"
  exit 1
}
bundle exec rails assets:clean
bundle exec rails db:migrate
