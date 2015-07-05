require 'pp'
require 'yaml'
require 'optparse'
require 'date'
require_relative 'lib/project'

def default_file_path
  "projects.yml"
end

def parse_options(argv)
  # Parse options
  options = {}
  opt = OptionParser.new
  opt.on('-t [TASKNAME]') do |v|
    options[:taskname] = v
  end
  opt.on('-d') do |v|
    options[:duedate] = v
  end
  opt.on('-p [PROJECT]') do |v|
    options[:project] = v
  end
  opt.on('-s [SORTBY]') do |v|
    options[:sortby] = v
  end
  opt.on('-f [FILE_PATH]') do |v|
    options[:file_path] = v
  end
  opt.parse!(argv)
  options
end

projects = TaskHandler::Project.new
projects.load_projects

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

else

  options = parse_options(ARGV)
  projects.display_tasks({ project: options[:project], duedate: options[:duedate]})

end
