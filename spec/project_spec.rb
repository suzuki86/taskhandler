require 'spec_helper'

describe "TaskHanlder::Project" do
  describe "#convert_tasks_to_projects" do
    it "converts tasks to projects as expected" do
      project = TaskHandler::Project.new
      tasks_to_add = [
        {
          :project => "project1",
          :task => "task1",
          :duedate => "2015-08-01",
          :status => "open",
        }
      ]
      expected = [
        {
          "project" => "project1",
          "tasks" => [
            {
              "task_number" => 0,
              "task" => "task1",
              "due_date" => "2015-08-01",
              "status" => "open",
              "closed_at" => nil,
            }
          ]
        }
      ]
      project.convert_tasks_to_projects(tasks_to_add)
      expect(project.projects).to match expected
    end
  end

  describe "#convert_projects_to_tasks" do
    it "converts projects to tasks as expected" do
      project = TaskHandler::Project.new
      projects = [
        {
          "project" =>  'project_name1',
          "tasks" => [
            {
              "task" => "task_name1",
              "due_date" => Date.new(2015, 1, 1),
              "status" => "open"
            }
          ],
        },
        {
          "project" => 'project_name2',
          "tasks" => [
            {
              "task" => "task_name2",
              "due_date" => Date.new(2015, 2, 1),
              "status" => "open"
            }
          ]
        }
      ]
      project.convert_projects_to_tasks(projects)

      expected = [
        {
          task_number: 0,
          project: "project_name1",
          task: "task_name1",
          duedate: Date.new(2015, 1, 1),
          status: "open"
        },
        {
          task_number: 1,
          project: "project_name2",
          task: "task_name2",
          duedate: Date.new(2015, 2, 1),
          status: "open"
        },
      ]

      expect(project.tasks).to match expected
    end
  end

  describe "#build_task" do
    it "raises error when invalid date is passed as due date" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["", "test_project", "test_task", "2011-01-32"])
      end.to raise_error(ArgumentError)
    end

    it "raises error when invalid string is passed as due date" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["", "test_project", "test_task", "invalid_string"])
      end.to raise_error(ArgumentError)
    end

    it "raises error when empty string is passed as due date" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["", "test_project", "test_task", ""])
      end.to raise_error(ArgumentError)
    end

    it "raises error when nil is passed as due date" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["", "test_project", "test_task", nil])
      end.to raise_error(ArgumentError)
    end

    it "raises error when no due date is passed" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["", "test_project", "test_task"])
      end.to raise_error(ArgumentError)
    end

    it "returns expected hash" do
      project = TaskHandler::Project.new
      task = project.build_task(["", "test_project", "test_task", "2015-08-01"])
      expected = {
        "project" => "test_project",
        "tasks" => [
          {
            "task" => "test_task",
            "due_date" => Date.parse("2015-08-01"),
            "status" => "open"
          }
        ]
      }
      expect(task).to match expected
    end

    it "returns expected hash when today is passed as due date" do
      project = TaskHandler::Project.new
      task = project.build_task(["", "test_project", "test_task", "today"])
      expected = {
        "project" => "test_project",
        "tasks" => [
          {
            "task" => "test_task",
            "due_date" => Date.today,
            "status" => "open"
          }
        ]
      }
      expect(task).to match expected
    end
  end

  describe "#add_task" do
    it "adds task as expected" do
      require 'tempfile'
      project = TaskHandler::Project.new
      tmpfile = Tempfile.open(["projects", ".yml"]) do |fp|
        project.load_projects(fp.path)
      end
      tasks_to_add = project.build_task(
        ["", "test_project", "test_task", "today"]
      )
      project.add_task(tasks_to_add)
      expected = [{
        "project" => "test_project",
        "tasks" => [
          {
            "task" => "test_task",
            "due_date" => Date.today,
            "status" => "open"
          }
        ]
      }]
      expect(project.projects).to match expected
    end
  end

  describe "#delete_task" do
    it "deletes specified task collectly" do
      require 'tempfile'
      project = TaskHandler::Project.new
      tmpfile = Tempfile.open(["projects", ".yml"]) do |fp|
        project.load_projects(fp.path)
      end
      tasks_to_add = project.build_task(
        ["", "test_project", "test_task", "today"]
      )
      project.add_task(tasks_to_add)
      project.delete_task(0)
      expect(project.projects).to match []
    end
  end


  describe "#load_config" do
    it "loads config from config.yml" do
      project = TaskHandler::Project.new
      project.load_config
      expected = {
       "project_file_path" => "~/.taskhandler/projects.yml"
      }
      expect(project.config).to match expected
      expect(project.config["project_file_path"]).to eq "~/.taskhandler/projects.yml"
    end
  end

end
