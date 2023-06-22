defmodule Demo.Services.ParseDocumentContent do
  @moduledoc """
  A mock service that simulates the parsing of a document into
  raw text and storing the result in the database.

  In a real-world application, this service would call
  an external service to parse the document.
  """

  alias Demo.Workflows.Document

  @spec call(Document.t()) :: {:ok, Document.t()} | {:error, any()}
  def call(%Document{} = document) do
    document = parse(document)
    {:ok, document}
  end

  defp parse(%Document{type: "application/pdf"} = document) do
    Map.put(document, :parsed_content, example_map())
  end

  defp example_map() do
    %{
      "amount" => Enum.random(5_000..15_000),
      "iban" => "NL02ABNA#{Enum.random(100_000_000..999_999_999)}"
    }
  end
end
