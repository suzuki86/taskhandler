module TaskHandler
  class Project
    attr_reader :projects
    attr_reader :tasks
    attr_reader :config

    def config
      @config ||= Config.load
    end

    def project_file_path
      if config && !config['project_file_path'].empty?
        config['project_file_path']
      else
        Config.default_file_path
      end
    end

    def load_projects(filepath)
      if !filepath.nil?
        @projects = YAML.load_file filepath
      elsif File.exists?(Config.default_file_path)
        @projects = YAML.load_file project_file_path
      else
        @projects = []
      end

      if @projects.is_a?(Array)
        @tasks = convert_projects_to_tasks(@projects)
      else
        @projects = []
        @tasks = []
      end
    end

    def latest_task_number(tasks)
      task_numbers = []
      if tasks && tasks != []
        tasks.each do |task|
          task_numbers << task[:task_number]
        end
        task_numbers.max
      else
        -1
      end
    end

    def build_task(argv)
      arg_project = argv[1]
      arg_task = argv[2]
      arg_duedate = argv[3]

      if arg_duedate === "today"
        arg_duedate = Date.today
      else
        begin
          arg_duedate = Date.parse(arg_duedate)
        rescue => e
          raise ArgumentError, "Due date you passed is invalid date. Task was not added."
        end
      end

      task_to_add = {
        "project" => arg_project,
        "tasks" => [
          {
            "task_number" => latest_task_number(@tasks) + 1,
            "task" => arg_task,
            "due_date" => arg_duedate,
            "status" => STATUS_OPEN,
            "closed_at" => nil
          }
        ]
      }
    end

    def add_task(task)
      @projects << task
    end

    def delete_task(task_number)
      @tasks.delete_at(task_number.to_i)
      convert_tasks_to_projects(@tasks)
    end

    def open_task(task_number)
      @tasks[task_number.to_i][:status] = STATUS_OPEN
      convert_tasks_to_projects(@tasks)
    end

    def close_task(task_number)
      @tasks[task_number.to_i][:status] = STATUS_CLOSED
      @tasks[task_number.to_i][:closed_at] = Date.today
      convert_tasks_to_projects(@tasks)
    end

    def display_tasks(filters)

      tasks_to_display = @tasks

      # Hide closed tasks.
      if filters[:display_all].nil?
        tasks_to_display = tasks_to_display.select { |item| item[:status] == STATUS_OPEN || item[:status].nil?  }
      end

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
        task[:project] = "[" + task[:project]  + "]"
        result = task.map{ |k, v| v }.join(" ")
        if task[:status] == "closed"
          puts result.colorize(:green)
        else
          puts result
        end
      end
    end

    def display_stats
      open_tasks = @tasks.select do |item|
        item[:status] == STATUS_OPEN || item[:status].nil?
      end
      closed_tasks = tasks.select do |item|
        item[:status] == STATUS_CLOSED
      end

      puts "open: " + open_tasks.length.to_s
      puts "closed: " + closed_tasks.length.to_s
    end

    def convert_projects_to_tasks(projects)
      counter = 0
      tasks = []
      projects.each do |project|
        project['tasks'].each do |task|
          if task['due_date'].nil?
            task['due_date'] = 'None'
          end
          tasks << {
            task_number: counter,
            project: project['project'],
            task: task['task'],
            duedate: task['due_date'],
            status: task['status'],
          }
          counter += 1
        end
      end
      @tasks = tasks
    end

    def convert_tasks_to_projects(tasks)
      results = []
      tasks.each_with_index do |task, task_number|
        found_flag = false

        # Find project
        results.each_with_index do |result, index|
          if result["project"] == task[:project]
            results[index]["tasks"] << {
              "task_number" => task_number,
              "task" => task[:task],
              "due_date" => task[:duedate],
              "status" => task[:status],
              "closed_at" => task[:closed_at],
            }
            found_flag = true
          end
        end

        if !found_flag
          results << {
            "project" => task[:project],
            "tasks" => [{
              "task_number" => task_number,
              "task" => task[:task],
              "due_date" => task[:duedate],
              "status" => task[:status],
              "closed_at" => task[:closed_at],
            }]
          }
        end

      end 
      @projects = results
    end

    def write_to_yaml(projects)
      if !File.exists?(Config.default_file_path)
        create_project_file
      end
      File.write project_file_path, projects.to_yaml
    end

  end
end
