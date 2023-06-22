defmodule Demo.WorkflowsTest do
  use ExUnit.Case, async: true

  alias Demo.Workflows
  alias Demo.Workflows.Document
  alias Demo.Workflows.Workflow

  setup do
    {:ok, workflows} = Workflows.start_link(name: {:global, UUID.uuid4()})
    %{workflows: workflows}
  end

  test "creates a new workflow", %{workflows: workflows} do
    assert Workflows.list_workflows(workflows) == %{}

    document = %Document{filename: "test.pdf"}
    assert :ok = Workflows.create_workflow(document, workflows)

    assert [{id, workflow}] = workflows |> Workflows.list_workflows() |> Map.to_list()

    assert workflow.id == id
    assert workflow.status == :pending
    assert workflow.document.filename == "test.pdf"
  end

  test "checkout workflow marks the workflow as running", %{workflows: workflows} do
    document = %Document{filename: "test.pdf"}

    assert :ok = Workflows.create_workflow(document, workflows)

    assert workflow = Workflows.get_next_pending_workflow(workflows)
    assert workflow.status == :running
    assert workflow.document.filename == "test.pdf"

    workflow = get_workflow(workflows)
    assert workflow.status == :running
  end

  test "checkout workflow returns nil if no pending workflow exists", %{workflows: workflows} do
    assert Workflows.get_next_pending_workflow(workflows) == nil
  end

  test "updates a workflow", %{workflows: workflows} do
    document = %Document{filename: "test.pdf"}
    assert :ok = Workflows.create_workflow(document, workflows)
    workflow = get_workflow(workflows)

    completed_workflow = Workflow.mark_as_completed(workflow)
    assert :ok = Workflows.update_workflow(completed_workflow, workflows)

    workflow = get_workflow(workflows)
    assert workflow.id == completed_workflow.id
    assert workflow.status == :completed
  end

  test "get workflow by id returns the correct workflow", %{workflows: workflows} do
    document = %Document{filename: "test.pdf"}
    assert :ok = Workflows.create_workflow(document, workflows)
    workflow = get_workflow(workflows)

    result = Workflows.get_workflow(workflow.id, workflows)
    assert result.id == workflow.id
  end

  defp get_workflow(workflows) do
    [{_id, workflow}] = workflows |> Workflows.list_workflows() |> Map.to_list()
    workflow
  end
end
