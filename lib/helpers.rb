require_relative './etna/clients'
require_relative './etna/environment_scoped'

module WithEtnaClients
  def environment
    EtnaApp.instance.environment
  end

  def token
    if environment == :many
      raise "You have multiple environments configured, please specify your environment by adding --environment #{@config.keys.join("|")}"
    elsif environment == :none
      raise "You do not have a successfully configured environment, please run #{program_name} config set https://polyphemus.ucsf.edu"
    end

    env_token = ENV['TOKEN']
    if !env_token
      puts "No environment variable TOKEN is set.  You should set your token with `export TOKEN=<your.janus.token>` before running."
      redirect = EtnaApp.instance.config(:auth_redirect)

      if redirect.nil? && EtnaApp.instance.environment == :production
        redirect = 'https://janus.ucsf.edu/'
      end

      unless redirect.nil?
        puts "Open your browser to #{redirect} to complete login and copy your token."
      end

      exit
    end

    env_token
  end

  def magma_client
    @magma_client ||= Etna::Clients::Magma.new(
        token: token,
        ignore_ssl: EtnaApp.instance.config(:ignore_ssl),
        # Persistent connections cause problem with magma restarts, until we can fix that we should force them
        # to close + reopen each request.
        persistent: false,
        **EtnaApp.instance.config(:magma, environment) || {})
  end

  def metis_client
    @metis_client ||= Etna::Clients::Metis.new(
        token: token,
        ignore_ssl: EtnaApp.instance.config(:ignore_ssl),
        **EtnaApp.instance.config(:metis, environment) || {})
  end

  def janus_client
    @janus_client ||= Etna::Clients::Janus.new(
        token: token,
        ignore_ssl: EtnaApp.instance.config(:ignore_ssl),
        **EtnaApp.instance.config(:janus, environment) || {})
  end

  def polyphemus_client
    @polyphemus_client ||= Etna::Clients::Polyphemus.new(
        token: token,
        ignore_ssl: EtnaApp.instance.config(:ignore_ssl),
        **EtnaApp.instance.config(:polyphemus, environment) || {})
  end
end

module WithLogger
  def logger
    EtnaApp.instance.logger
  end
end

module StrongConfirmation
  def confirm
    puts "Confirm Y/n:"
    input = STDIN.gets.chomp
    if input != "Y"
      return false
    end

    true
  end
end

WithEtnaClientsByEnvironment = EnvironmentScoped.new do
  include WithEtnaClients
end
