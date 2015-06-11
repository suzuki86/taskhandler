require 'pp'
require 'yaml'
require 'optparse'

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

# Output tasks
tasks = []
projects.each do |project|
  project['tasks'].each do |task|
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
  tasks = tasks.sort_by { |k| k[:duedate] }
end

tasks.each do |task|
  puts task.map{ |k, v| v }.join(" ")
end
