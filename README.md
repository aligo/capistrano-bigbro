# Capistrano::Bigbro


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-bigbro'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-bigbro

## Usage

```ruby
    # Capfile

    require 'capistrano/bigbro'
```

Configurable options, shown here with defaults:

```ruby
    set :bigbro_default_hooks, -> { true }
    set :bigbro_monit_conf_dir, -> { '/etc/monit.d' }
    set :bigbro_monit_use_sudo, -> { true }
    set :bigbro_monit_bin, -> { '/usr/bin/monit' }
    set :bigbro_template_path, -> { 'config/deploy/templates' }
    set :bigbro_template, -> { 'bigbro.conf' }
    set :bigbro_process_name, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :bigbro_role, -> { :app }
    set :bigbro_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
```

Add `bigbro.conf.erb` to `config/deploy/templates`:

```erb
<% bundle_exec = "/bin/su - #{@role.user} -c 'cd #{current_path} && RAILS_ENV=#{fetch(:bigbro_env)} #{SSHKit.config.command_map[:bundle]} exec" %>

check process <%= fetch(:bigbro_process_name) %>_puma
  with pidfile "<%= fetch(:puma_pid) %>"
  start program = "<%= bundle_exec %> puma -C <%= fetch(:puma_conf) %> --daemon'"
  stop program = "<%= bundle_exec %> pumactl -S <%= fetch(:puma_state) %> stop'"
  group <%= fetch(:bigbro_process_name) %>

check process <%= fetch(:bigbro_process_name) %>_sidekiq
  with pidfile "<%= shared_path.join('tmp', 'pids', 'sidekiq.pid') %>"
  start program = "<%= bundle_exec %> sidekiq --index 0 --pidfile <%= shared_path.join('tmp', 'pids', 'sidekiq.pid') %> --logfile <%= shared_path.join('log', 'sidekiq.log') %> --config <%= fetch(:sidekiq_config) %>'" with timeout 30 seconds
  stop program = "<%= bundle_exec %> sidekiqctl stop <%= shared_path.join('tmp', 'pids', 'sidekiq.pid') %> -d'" with timeout 15 seconds
  group <%= fetch(:bigbro_process_name) %>

...
    
```

Capistrano Tasks:

```
    cap bigbro:config                 # Generate Monit Configure to monit_conf_dir
    cap bigbro:monitor                # Run Monit monitor script
    cap bigbro:unmonitor              # Run Monit unmonitor script
    cap bigbro:reload                 # Run Monit reload script
    cap bigbro:restart                # Run Monit restart script
    cap bigbro:start                  # Run Monit start script
    cap bigbro:status                 # Run Monit status script
    cap bigbro:stop                   # Run Monit stop script
    cap bigbro:summary                # Run Monit summary scrip
```