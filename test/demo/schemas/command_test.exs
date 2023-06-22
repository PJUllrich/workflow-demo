defmodule Demo.CommandTest do
  use ExUnit.Case

  alias Demo.Command
  alias Demo.Workflows.Document
  alias Demo.Workflows.Workflow

  setup do
    document = %Document{filename: "foo.pdf", parsed_content: %{"amount" => 10_000}}
    workflow = %Workflow{id: UUID.uuid4(), document: document}
    %{document: document, workflow: workflow}
  end

  describe "get_field/3" do
    test "fetches a field from a workflow", %{workflow: workflow} do
      assert Command.get_field(["workflow", "id"], workflow, nil) == workflow.id
    end

    test "fetches a field from a document", %{workflow: workflow, document: document} do
      assert Command.get_field(["document", "filename"], workflow, nil) == document.filename
    end

    test "fetches a field from the parsed_content", %{workflow: workflow} do
      assert Command.get_field(["document", "parsed_content", "amount"], workflow, nil) == 10_000
    end

    test "fetches a field from a previous_result", %{workflow: workflow} do
      previous_result = %{"decision" => "process"}
      assert Command.get_field(["previous", "decision"], workflow, previous_result) == "process"
    end
  end
end
