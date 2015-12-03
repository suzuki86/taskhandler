require 'pp'
require 'yaml'
require 'date'
require 'colorize'
require 'taskhandler/version'
require 'taskhandler/config'
require 'taskhandler/setup'
require 'taskhandler/project'
require 'taskhandler/option_parser'

module TaskHandler

  STATUS_OPEN = "open"
  STATUS_CLOSED = "closed"

  class Runner
    def argv
      ARGV
    end

    def options
      @options ||= TaskHandler::OptionParser.parse_options(argv)
    end

    def projects
      @projects ||= TaskHandler::Project.new
    end

    def setup
      @setup ||= TaskHandler::Setup.new
    end

    def invoke
      # Parse subcommand
      subcommand = argv[0]

      if subcommand == "init"
        setup.init
        return
      end

      projects.load_projects(options[:file_path])

      if subcommand == "add"

        tasks_to_add = projects.build_task(argv)
        projects.add_task(tasks_to_add)
        projects.write_to_yaml(projects.projects)

      elsif subcommand == "del"

        projects.delete_task(argv[1])
        projects.write_to_yaml(projects.projects)

      elsif subcommand == "open"

        projects.open_task(argv[1])
        projects.write_to_yaml(projects.projects)

      elsif subcommand == "close"

        projects.close_task(argv[1])
        projects.write_to_yaml(projects.projects)

      elsif subcommand == "stats"

        projects.display_stats

      else

        projects.display_tasks(
          {
            project: options[:project],
            duedate: options[:duedate],
            display_all: options[:display_all],
          }
        )

      end
    end

  end
end
