require 'pp'
require 'yaml'
require 'optparse'
require 'date'

def default_file_path
  "projects.yml"
end

def write_to_yaml(projects)
  File.write default_file_path, projects.to_yaml
end

def load_projects(filepath)
  # Load task files
  if !filepath.nil?
    projects = YAML.load_file filepath
  else
    projects = YAML.load_file default_file_path
  end
end

def delete_task
  arg_task_number = ARGV[1]
  projects = YAML.load_file default_file_path
  tasks = convert_projects_to_tasks(projects)
  tasks.delete_at(arg_task_number.to_i)
  tasks
end

def display_tasks(tasks)
  tasks.each_with_index do |task, index|
    puts index.to_s + " " + task.map{ |k, v| v }.join(" ")
  end
end

def convert_projects_to_tasks(projects)
  tasks = []
  projects.each do |project|
    project['tasks'].each do |task|
      if task['due_date'].nil?
        task['due_date'] = 'None'
      end
      tasks << {
        project: project['project'],
        task: task['task'],
        duedate: task['due_date'],
      }
    end
  end
  tasks
end

def convert_tasks_to_projects(tasks)
  
  results = []

  tasks.each do |task|

    found_flag = false

    # Find project
    results.each_with_index do |result, index|
      if result["project"] == task[:project]
        results[index]["tasks"] << {
          "task" => task[:task],
          "due_date" => task[:duedate],
        }
        found_flag = true
      end
    end

    if !found_flag
      results << {
        "project" => task[:project],
        "tasks" => [{ "task" => task[:task], "due_date" => task[:duedate] }]
      }
    end

  end 

  results

end

def parse_options(argv)
  argv = ARGV
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

# Parse subcommand
subcommand = ARGV[0]

if subcommand == "add"
  arg_project = ARGV[1]
  arg_task = ARGV[2]
  arg_duedate = ARGV[3]
  projects = YAML.load_file default_file_path
  projects << {
    "project" => arg_project,
    "tasks" => [
      {
        "task" => arg_task,
        "due_date" => Date.parse(arg_duedate)
      }
    ]
  }
  write_to_yaml(projects)
elsif subcommand == "del"
  delete_task
  modified_projects = convert_tasks_to_projects(delete_task)
  write_to_yaml(modified_projects)
else
  options = parse_options(ARGV)

  # Load task files
  projects = load_projects(options[:file_path])
  tasks = convert_projects_to_tasks(projects)

  if !options[:project].nil?
    tasks = tasks.select { |item| item[:project] == options[:project] }
  end

  if !options[:duedate].nil?
    # Extract item that does not be set due date.
    tasks, indefinite_tasks = tasks.partition do |item|
      item[:duedate].kind_of?(Date)
    end

    tasks = tasks.sort_by { |k| k[:duedate] }
    tasks.concat(indefinite_tasks)
  end

  display_tasks(tasks)

end
