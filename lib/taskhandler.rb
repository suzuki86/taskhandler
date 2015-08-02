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

        arg_project = argv[1]
        arg_task = argv[2]
        arg_duedate = argv[3]

        if arg_duedate === "today"
          arg_duedate = Date.today
        else
          arg_duedate = Date.parse(arg_duedate)
        end
        
        task_to_add = {
          "project" => arg_project,
          "tasks" => [
            {
              "task" => arg_task,
              "due_date" => arg_duedate,
              "status" => "open"
            }
          ]
        }
        projects.add_task(task_to_add) 

      elsif subcommand == "del"

        projects.delete_task(argv[1])

      elsif subcommand == "open"

        projects.open_task(argv[1])

      elsif subcommand == "close"

        projects.close_task(argv[1])

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
