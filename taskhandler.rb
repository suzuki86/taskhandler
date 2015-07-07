require 'pp'
require 'yaml'
require 'date'
require_relative 'lib/project'
require_relative 'lib/option_parser'

options = TaskHandler::OptionParser.parse_options(ARGV)
projects = TaskHandler::Project.new
projects.load_projects(options[:file_path])

# Parse subcommand
subcommand = ARGV[0]

if subcommand == "add"

  arg_project = ARGV[1]
  arg_task = ARGV[2]
  arg_duedate = ARGV[3]
  
  task_to_add = {
    "project" => arg_project,
    "tasks" => [
      {
        "task" => arg_task,
        "due_date" => Date.parse(arg_duedate)
      }
    ]
  }
  projects.add_task(task_to_add) 

elsif subcommand == "del"

  projects.delete_task(ARGV[1])

elsif subcommand == "open"

  projects.open_task(ARGV[1])

elsif subcommand == "close"

  projects.close_task(ARGV[1])

else

  projects.display_tasks(
    {
      project: options[:project],
      duedate: options[:duedate],
      display_all: options[:display_all],
    }
  )

end
