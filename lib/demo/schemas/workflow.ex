defmodule Demo.Workflows.Workflow do
  @moduledoc """
  This struct represents a document processing workflow with multiple
  user-configured steps. Each step is a `Demo.Command`.

  Workflows are instantiated and executed by the `Demo.Engine`.
  The engine will create a new workflow for every incoming document.
  The processing of the document happens as a series of `steps`, which
  are `Demo.Command` structs. The steps are executed in sequence
  and every command receives three parameters:

    1. The `Workflow` struct that contains the `Document`.
    2. The `Parameters` that the user configured for the step.
    3. The `Previous_result` which is the result that the previous
    step returned to the engine after completing successfully.

  Workflows are meant to be:
    * `configurable` by the user through e.g. an UI
    * `composable`. Every step is a `Demo.Command` and commands can be
    easily added and removed by a user.
    * `suspendable`. That means that a workflow can be
    stopped by the engine after every step. This might happen
    if the workflow needs to wait for some external service or manual process
    to complete. Once the response from this external factor reaches
    the engine, the engine can fetch and continue a workflow without
    breaking the state of the document or the workflow.

  You can see an example workflow in `Mocks.ExampleWorkflow`.
  """
  require Logger

  alias Demo.Command

  defstruct [:id, :document, :parent_workflow, :result, status: :pending, steps: []]

  def mark_as_completed(workflow) do
    mark_as(workflow, :completed)
  end

  def mark_as_aborted(workflow) do
    mark_as(workflow, :aborted)
  end

  def mark_as_waiting(workflow) do
    mark_as(workflow, :waiting)
  end

  def mark_as_running(workflow) do
    mark_as(workflow, :running)
  end

  def mark_as_pending(workflow) do
    mark_as(workflow, :pending)
  end

  defp mark_as(workflow, status) do
    Logger.debug("Marking Workflow #{workflow.id} as #{status}")
    Map.put(workflow, :status, status)
  end

  def waiting?(workflow), do: workflow.status == :waiting
  def aborted?(workflow), do: workflow.status == :aborted

  def complete_workflow(workflow) do
    last_command = workflow.steps |> Enum.sort_by(& &1.position) |> List.last()
    last_result = if last_command, do: last_command.result, else: nil

    workflow
    |> put_result(last_result)
    |> mark_as_completed()
  end

  def all_commands_completed?(workflow) do
    Enum.all?(workflow.steps, &Command.completed?/1)
  end

  def put_result(workflow, result) do
    Map.put(workflow, :result, result)
  end

  def update_command(workflow, command) do
    steps =
      workflow.steps
      |> Enum.sort_by(& &1.position)
      |> List.replace_at(command.position, command)

    Map.put(workflow, :steps, steps)
  end

  def record_response(workflow, response) do
    workflow
    |> mark_as_pending()
    |> put_response_in_waiting_command(response)
  end

  def put_response_in_waiting_command(workflow, response) do
    waiting_command = Enum.find(workflow.steps, &(&1.status == :waiting))
    waiting_command = Command.put_result(waiting_command, response)
    update_command(workflow, waiting_command)
  end
end
