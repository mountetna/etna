require 'date'
require 'logger'
require 'rollbar'
require 'tempfile'
require_relative 'helpers'


class EtnaCommands
  class Help < Etna::Command
    usage 'List this help'

    def execute
      puts 'Commands:'
      EtnaApp.instance.commands.each do |name, cmd|
        puts cmd.usage
      end
    end
  end

  class CreateProject < Etna::Command
    include WithEtnaClientsByEnvironment
    include WithLogger
    usage 'create_project <environment> <filepath>'

    def execute(env, filepath)
      @environ = environment(env)

      create_project_workflow = Etna::Clients::Magma::CreateProjectFromJsonWorkflow.new(
        magma_client: @environ.magma_client,
        janus_client: @environ.janus_client,
        filepath: filepath)
      create_project_workflow.create!
    end
  end

  class Console < Etna::Command
    usage 'Open a console with a connected Etna instance.'

    def execute
      require 'irb'
      ARGV.clear
      IRB.start
    end

    def setup(config)
      super
    end
  end
end
