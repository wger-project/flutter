source "https://rubygems.org"

gem "fastlane"
gem 'logger'
gem 'mutex_m'
gem 'abbrev'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
