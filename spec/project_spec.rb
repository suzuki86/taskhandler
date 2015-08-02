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
end
