defmodule DemoWeb.Controller do
  use GenServer

  alias Demo.Workflows
  alias Demo.Workflows.Workflow

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    {:ok, :initial_state}
  end

  def handle_info({:post, :review_response, %{"workflow_id" => workflow_id} = params}, state) do
    workflow_id
    |> Workflows.get_workflow()
    |> Workflow.record_response(params)
    |> Workflows.update_workflow()

    {:noreply, state}
  end

  def handle_info({:post, :new_document, document}, state) do
    :ok = Demo.Workflows.create_workflow(document)

    {:noreply, state}
  end
end
