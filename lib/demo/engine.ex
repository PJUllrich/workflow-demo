defmodule Demo.Engine do
  @moduledoc """

  """

  use GenServer

  @me __MODULE__

  alias Demo.Command
  alias Demo.Workflows.Workflow

  def start_link(init_args) do
    GenServer.start_link(@me, init_args, name: @me)
  end

  def init(args) do
    workflows = Keyword.get(args, :workflows, Demo.Workflows)

    schedule_run()
    {:ok, %{workflows: workflows}}
  end

  def handle_info(:run, %{workflows: workflows} = state) do
    case workflows.get_next_pending_workflow() do
      nil ->
        nil

      workflow ->
        workflow = run_workflow(workflow)
        :ok = workflows.update_workflow(workflow)
    end

    schedule_run()
    {:noreply, state}
  end

  def run_workflow(workflow) do
    workflow.steps
    |> Enum.sort_by(& &1.position, :asc)
    |> Enum.reduce_while({workflow, nil}, fn command, {workflow, previous_command} ->
      case command.status do
        :completed ->
          {:cont, {workflow, command}}

        :waiting ->
          command = Command.mark_as_completed(command)
          workflow = Workflow.update_command(workflow, command)
          {:cont, {workflow, command}}

        :pending ->
          previous_result = if previous_command, do: previous_command.result, else: %{}

          case Command.run(command, workflow, previous_result) do
            {:ok, workflow, :wait} ->
              command = Command.put_result(command, :wait)
              command = Command.mark_as_waiting(command)
              workflow = Workflow.update_command(workflow, command)
              workflow = Workflow.mark_as_waiting(workflow)
              {:halt, {workflow, command}}

            {:ok, workflow, :abort} ->
              command = Command.complete_command(command, :abort)
              workflow = Workflow.update_command(workflow, command)
              workflow = Workflow.mark_as_aborted(workflow)
              {:halt, {workflow, command}}

            {:ok, workflow, result} ->
              command = Command.complete_command(command, result)
              workflow = Workflow.update_command(workflow, command)
              {:cont, {workflow, command}}
          end
      end
    end)
    |> then(fn {workflow, _command} ->
      cond do
        Workflow.aborted?(workflow) || Workflow.waiting?(workflow) ->
          workflow

        Workflow.all_commands_completed?(workflow) ->
          Workflow.complete_workflow(workflow)
      end
    end)
  end

  defp schedule_run() do
    Process.send_after(@me, :run, 1_000)
  end
end
