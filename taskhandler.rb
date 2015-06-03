require 'pp'
require 'yaml'
require 'optparse'

# Parse options
options = {}
opt = OptionParser.new
opt.on('-t [TASKNAME]') do |v|
  options[:taskname] = v
end
# opt.on('-d [DUEDATE]') do |v|
opt.on('-d') do |v|
  options[:duedate] = v
end
opt.on('-p [PROJECT]') do |v|
  options[:project] = v
end
opt.on('-s [SORTBY]') do |v|
  options[:sortby] = v
end
opt.parse!(ARGV)

# Load task files
projects = YAML.load_file "projects.yml"
# pp projects[0]['tasks']

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
