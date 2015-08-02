require 'pp'
require 'yaml'
require 'date'
require 'taskhandler/version'
require 'taskhandler/project'
require 'taskhandler/option_parser'

module TaskHandler
  class Runner
    def self.invoke
      argv = ARGV
      options = TaskHandler::OptionParser.parse_options(argv)
      projects = TaskHandler::Project.new
      projects.load_projects(options[:file_path])

      # Parse subcommand
      subcommand = argv[0]

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
