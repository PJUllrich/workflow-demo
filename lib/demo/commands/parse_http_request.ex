defmodule Demo.Commands.ParseHTTPRequest do
  @moduledoc """
  This Command parses the body of an HTTP Request that came in
  from a customer server. It takes the predefined parameters
  from the request body and returns the fields as map with string-keys.
  """

  @behaviour Demo.Command

  @impl true
  def execute(
        workflow,
        %{take_params: take_params},
        request_body
      ) do
    {:ok, workflow, Map.take(request_body, take_params)}
  end
end
