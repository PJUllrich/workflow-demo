defmodule Demo.Workflows do
  @moduledoc """
  The Context that simulates CRUD operations for Workflows.
  """

  use GenServer

  alias Mocks.ExampleWorkflow
  alias Demo.Workflows.Workflow

  require Logger

  @me __MODULE__

  ## Client Functions

  def start_link(init_args) do
    name = Keyword.get(init_args, :name, @me)
    GenServer.start_link(@me, [init_args], name: name)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def list_workflows(name \\ @me) do
    GenServer.call(name, :list_workflows)
  end

  def get_workflow(id, name \\ @me) do
    GenServer.call(name, {:get_workflow, id})
  end

  def create_workflow(document, name \\ @me) do
    GenServer.call(name, {:create_workflow, document})
  end

  def get_next_pending_workflow(name \\ @me) do
    GenServer.call(name, :get_next_pending_workflow)
  end

  def update_workflow(workflow, name \\ @me) do
    GenServer.call(name, {:update_workflow, workflow})
  end

  ## Callbacks

  def handle_call(:list_workflows, _from, workflows) do
    {:reply, workflows, workflows}
  end

  def handle_call({:get_workflow, id}, _from, workflows) do
    workflow = Map.get(workflows, id)
    {:reply, workflow, workflows}
  end

  def handle_call({:create_workflow, document}, _from, workflows) do
    workflow = ExampleWorkflow.new(document)
    workflows = Map.put(workflows, workflow.id, workflow)

    Logger.debug("Created new workflow for document: #{document.filename}")

    {:reply, :ok, workflows}
  end

  def handle_call(:get_next_pending_workflow, _from, workflows) do
    workflow_or_nil = do_get_next_pending_workflow(workflows)

    case workflow_or_nil do
      nil ->
        {:reply, nil, workflows}

      pending_workflow ->
        running_workflow = Workflow.mark_as_running(pending_workflow)
        workflows = do_update_workflow(running_workflow, workflows)
        {:reply, running_workflow, workflows}
    end
  end

  def handle_call({:update_workflow, workflow}, _from, worklows) do
    worklows = do_update_workflow(workflow, worklows)
    {:reply, :ok, worklows}
  end

  defp do_get_next_pending_workflow(workflows) do
    result = Enum.find(workflows, fn {_id, workflow} -> workflow.status == :pending end)

    case result do
      nil -> nil
      {_id, workflow} -> workflow
    end
  end

  defp do_update_workflow(workflow, workflows) do
    Map.put(workflows, workflow.id, workflow)
  end
end
