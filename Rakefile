require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'voxpupuli/release/rake_tasks'
require 'puppet-strings/tasks'

PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')

exclude_paths = %w(
  pkg/**/*
  vendor/**/*
  .vendor/**/*
  spec/**/*
)
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc 'Run tests metadata_lint, release_checks'
task test: [
  :metadata_lint,
  :release_checks,
]

desc 'Run spec tests of exactly one specfile'
# usage: bundle exec rake spec_single[<path to specfile>]
task :spec_single, [:specfile] do |t, args|
  RSpec::Core::RakeTask.new(:spec_onetest) do |t|
    t.pattern = args[:specfile]
    t.rspec_opts = ['--color']
  end

  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_onetest].invoke
  # Rake::Task[:spec_clean].invoke
end


# vim: syntax=ruby
