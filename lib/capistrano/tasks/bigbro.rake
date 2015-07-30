namespace :load do
  task :defaults do
    set :bigbro_default_hooks, -> { true }
    set :bigbro_monit_conf_dir, -> { '/etc/monit.d' }
    set :bigbro_monit_use_sudo, -> { true }
    set :bigbro_monit_bin, -> { '/usr/bin/monit' }
    set :bigbro_template_path, -> { 'config/deploy/templates' }
    set :bigbro_template, -> { 'bigbro.conf' }
    set :bigbro_process_name, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :bigbro_role, -> { :app }
    set :bigbro_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
  end
end

namespace :deploy do
  before :starting, :check_sidekiq_hooks do
    invoke 'bigbro:add_default_hooks' if fetch(:bigbro_default_hooks)
  end
end

namespace :bigbro do

  task :add_default_hooks do
    before  'deploy:publishing',  'bigbro:config'
    after   'deploy:published',   'bigbro:restart'
  end

  desc 'Generate Monit Configure to monit_conf_dir'
  task :config do
    on roles(fetch(:bigbro_role)) do |role|
      @role = role
      upload! bigbro_template(fetch(:bigbro_template)), "#{fetch(:tmp_dir)}/bigbro.conf"

      mv_command = "mv #{fetch(:tmp_dir)}/bigbro.conf #{fetch(:bigbro_monit_conf_dir)}/#{fetch(:bigbro_process_name)}.conf"
      sudo_if_needed mv_command

      sudo_if_needed "#{fetch(:bigbro_monit_bin)} reload"
    end
  end

  desc 'Run Monit monitor script'
  task :monitor do
    on roles(fetch(:bigbro_role)) do |role|
      begin
        sudo_if_needed "#{fetch(:bigbro_monit_bin)} monitor -g #{fetch(:bigbro_process_name)}"
      rescue
        invoke 'bigbro:config'
        sudo_if_needed "#{fetch(:bigbro_monit_bin)} monitor -g #{fetch(:bigbro_process_name)}"
      end
    end
  end

  desc 'Run Monit unmonitor script'
  task :unmonitor do
    on roles(fetch(:bigbro_role)) do |role|
      begin
        sudo_if_needed "#{fetch(:bigbro_monit_bin)} unmonitor -g #{fetch(:bigbro_process_name)}"
      rescue
        # no worries here
      end
    end
  end

  %w[start stop restart reload summary status].each do |command|
    desc "Run Monit #{command} script"
    task command do
      on roles(fetch(:bigbro_role)) do |role|
        sudo_if_needed "#{fetch(:bigbro_monit_bin)} #{command} -g #{fetch(:bigbro_process_name)}"
      end
    end
  end

  def bigbro_template template_name
    config_file = "#{fetch(:bigbro_template_path)}/#{template_name}.erb"
    StringIO.new ERB.new(File.read(config_file)).result(binding)
  end

  def sudo_if_needed command
    send(use_sudo? ? :sudo : :execute, command)
  end

  def use_sudo?
    fetch(:bigbro_monit_use_sudo)
  end

end
