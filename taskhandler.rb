require 'pp'
require 'yaml'
require 'optparse'
require 'date'

module TaskHandler
  class Project
    attr_reader :projects
    attr_reader :tasks

    def load_projects(filepath = "projects.yml")
      if !filepath.nil?
        @projects = YAML.load_file filepath
      else
        @projects = YAML.load_file default_file_path
      end
      @tasks = convert_projects_to_tasks(@projects)
    end

    def add_task(task)
      @projects << task
      write_to_yaml(@projects)
    end

    def delete_task(task_number)
      @tasks.delete_at(task_number.to_i)
      convert_tasks_to_projects(@tasks)
      write_to_yaml(@projects)
    end

    def display_tasks(filters)

      tasks_to_display = @tasks

      if !filters[:project].nil?
        tasks_to_display = tasks_to_display.select { |item| item[:project] == filters[:project] }
      end

      if !filters[:duedate].nil?
        # Extract item that does not be set due date.
        tasks_to_display, indefinite_tasks = tasks_to_display.partition do |item|
          item[:duedate].kind_of?(Date)
        end

        tasks_to_display = tasks_to_display.sort_by { |k| k[:duedate] }
        tasks_to_display.concat(indefinite_tasks)
      end

      tasks_to_display.each_with_index do |task, index|
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
      @tasks = tasks
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
      @projects = results
    end

    def write_to_yaml(projects)
      File.write default_file_path, projects.to_yaml
    end

  end
end

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
