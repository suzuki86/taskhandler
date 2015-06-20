require 'pp'
require 'yaml'
require 'optparse'
require 'date'

default_file_path = "projects.yml"

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
opt.parse!(ARGV)

# Load task files
if !options[:file_path].nil?
  projects = YAML.load_file options[:file_path]
else
  projects = YAML.load_file default_file_path
end

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

tasks.each do |task|
  puts task.map{ |k, v| v }.join(" ")
end
