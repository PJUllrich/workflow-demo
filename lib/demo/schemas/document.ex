defmodule Demo.Workflows.Document do
  @moduledoc """
  This struct contains some example fields of a document
  that this application would process. It can contain a
  filename, type (e.g. `application/pdf`) and a parsed content
  text.
  """
  defstruct [:filename, :type, :parsed_content]
end
