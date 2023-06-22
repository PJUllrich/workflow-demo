defmodule Demo.Workflows.WorkflowTest do
  use ExUnit.Case, async: true

  alias Demo.Command
  alias Demo.Workflows.Workflow

  test "update_command/3 replaces an existing command" do
    command = %Command{position: 0, status: :pending}
    workflow = %Workflow{steps: [command]}

    updated_command = Map.put(command, :status, :waiting)
    updated_workflow = Workflow.update_command(workflow, updated_command)

    assert [updated_command] = updated_workflow.steps
    assert updated_command.status == :waiting
  end

  test "all_commands_completed/1 checks whether all commands are completed" do
    completed_command = %Command{position: 0, status: :completed}
    pending_command = %Command{position: 1, status: :pending}

    completed_workflow = %Workflow{steps: [completed_command, completed_command]}
    assert Workflow.all_commands_completed?(completed_workflow)

    uncompleted_workflow = %Workflow{steps: [completed_command, pending_command]}
    refute Workflow.all_commands_completed?(uncompleted_workflow)
  end

  test "record_response/2 updates the result of the waiting command" do
    completed_command = %Command{position: 0, status: :completed, result: :test}
    waiting_command = %Command{position: 1, status: :waiting, result: nil}

    waiting_workflow = %Workflow{status: :waiting, steps: [completed_command, waiting_command]}
    updated_workflow = Workflow.record_response(waiting_workflow, %{"decision" => "ignore"})

    assert updated_workflow.status == :pending

    [untouched_completed_command, updated_waiting_command] =
      Enum.sort_by(updated_workflow.steps, & &1.position)

    assert untouched_completed_command.status == :completed
    assert untouched_completed_command.result == :test

    assert updated_waiting_command.status == :waiting
    assert updated_waiting_command.result == %{"decision" => "ignore"}
  end
end
