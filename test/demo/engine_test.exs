defmodule Demo.EngineTest do
  use ExUnit.Case, async: true

  alias Demo.Engine
  alias Demo.Workflows.Workflow
  alias Demo.Workflows.Document
  alias Demo.Command
  alias Demo.Commands.EvaluateIfThenElse
  alias Demo.Commands.WaitForResponse

  test "completes a simple workflow" do
    workflow = build_simple_workflow(:test)
    completed_workflow = Engine.run_workflow(workflow)

    assert [updated_command] = completed_workflow.steps
    assert updated_command.status == :completed
    assert updated_command.result == :test

    assert completed_workflow.status == :completed
  end

  test "successfully aborts a workflow" do
    workflow = build_simple_workflow(:abort)

    aborted_workflow = Engine.run_workflow(workflow)

    assert [updated_command] = aborted_workflow.steps
    assert updated_command.status == :completed
    assert updated_command.result == :abort

    assert aborted_workflow.status == :aborted
  end

  test "successfully marks a workflow as waiting" do
    workflow = build_waiting_workflow()

    waiting_workflow = Engine.run_workflow(workflow)

    assert [updated_command] = waiting_workflow.steps
    assert updated_command.status == :waiting
    assert updated_command.result == :wait

    assert waiting_workflow.status == :waiting
  end

  test "skips completed steps" do
    workflow = build_multistep_workflow_with_completed_command(:test)
    completed_workflow = Engine.run_workflow(workflow)

    assert [wait_command, command_if_then_else] =
             Enum.sort_by(completed_workflow.steps, & &1.position)

    assert wait_command.status == :completed
    assert wait_command.result == :foo

    assert command_if_then_else.status == :completed
    assert command_if_then_else.result == :test

    assert completed_workflow.status == :completed
  end

  test "marks a waiting command as completed and uses its response for running subsequent command" do
    workflow = build_waiting_workflow_with_subsequent_command()
    completed_workflow = Engine.run_workflow(workflow)

    assert [wait_command, command_if_then_else] =
             Enum.sort_by(completed_workflow.steps, & &1.position)

    assert wait_command.status == :completed

    assert command_if_then_else.status == :completed
    assert command_if_then_else.result == :process
  end

  test "records the result of the last command on the workflow" do
    workflow = build_waiting_workflow_with_subsequent_command()
    completed_workflow = Engine.run_workflow(workflow)

    assert completed_workflow.result == :process
  end

  defp build_simple_workflow(result) do
    document = %Document{filename: "test"}

    command = %Command{
      position: 0,
      module: EvaluateIfThenElse,
      params: %{if: {["document", "filename"], :equals, "test"}, then: result, else: false}
    }

    %Workflow{id: "foo", steps: [command], document: document}
  end

  defp build_waiting_workflow() do
    document = %Document{filename: "test"}
    command = %Command{position: 0, module: WaitForResponse}

    %Workflow{id: "foo", steps: [command], document: document}
  end

  def build_multistep_workflow_with_completed_command(result) do
    document = %Document{filename: "test"}

    completed_command = %Command{
      position: 0,
      module: WaitForResponse,
      status: :completed,
      result: :foo
    }

    pending_command = %Command{
      position: 1,
      module: EvaluateIfThenElse,
      params: %{if: {["document", "filename"], :equals, "test"}, then: result, else: false},
      status: :pending
    }

    %Workflow{id: "foo", steps: [completed_command, pending_command], document: document}
  end

  defp build_waiting_workflow_with_subsequent_command() do
    document = %Document{filename: "test"}

    waiting_command = %Command{
      position: 0,
      module: WaitForResponse,
      status: :waiting,
      result: %{"decision" => "process"}
    }

    pending_command = %Command{
      position: 1,
      module: EvaluateIfThenElse,
      params: %{if: {["previous", "decision"], :equals, "process"}, then: :process, else: :ignore},
      status: :pending,
      result: nil
    }

    %Workflow{id: "foo", steps: [waiting_command, pending_command], document: document}
  end
end
