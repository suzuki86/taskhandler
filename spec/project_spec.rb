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
    it "raises error when invalid date passed as due date" do
      project = TaskHandler::Project.new
      expect do
        project.build_task(["test_project", "test_task", "2011-01-32"])
      end.to raise_error(ArgumentError)
    end
  end

end
