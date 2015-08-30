require 'spec_helper'

describe "TaskHanlder::Project" do
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
        project.build_task(["", "test_project", "test_task", "invalid_string"])
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
  end

end
