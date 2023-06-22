defmodule Demo.Commands.ParseDocumentTest do
  use ExUnit.Case, async: true

  alias Demo.Commands.ParseDocument

  describe "execute/3" do
    test "updates the parsed content field of the workflow document" do
      document = %Demo.Workflows.Document{
        filename: "file.pdf",
        type: "application/pdf",
        parsed_content: nil
      }

      workflow = %Demo.Workflows.Workflow{document: document}

      assert {:ok, workflow, nil} = ParseDocument.execute(workflow, nil, nil)

      assert %{"amount" => amount, "iban" => iban} = workflow.document.parsed_content
      assert is_integer(amount)
      assert "NL02ABNA" <> _number = iban
    end
  end
end
