defmodule Demo.Commands.ParseDocument do
  @moduledoc """
  This command parses the content of a document and stores the result
  in the `document.parsed_content`. This command assumes that the external
  service that does the actual parsing can be called synchronously.

  Ideally, the parsing could happen asynchronously, but async commands
  where not part of this version of the proof of concept but might be
  added later.

  The parsing strategy for different document types can be implemented
  `ParseDocumentContent` service. For this demo, I assumed that all
  documents are `PDFs`.
  """

  @behaviour Demo.Command

  alias Demo.Services.ParseDocumentContent

  @impl true
  def execute(workflow, _params, _previous_result) do
    with {:ok, document} <- ParseDocumentContent.call(workflow.document) do
      workflow = Map.put(workflow, :document, document)
      {:ok, workflow, nil}
    end
  end
end
