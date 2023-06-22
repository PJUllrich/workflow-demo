defmodule Demo.Commands.SendWebhookEvent do
  @moduledoc """
  A Command for sending a Webhook event to an external service.

  In this demo, this command doesn't sign the request body.
  In production, we would sign the request body with a secret
  that is known to the customer and that they can use to verify
  the validity and maybe also: integrity of the request body.
  """

  @behaviour Demo.Command

  @impl true
  def execute(
        workflow,
        %{url: url, payload: payload},
        previous_result,
        recipient \\ Mocks.CustomerServer
      ) do
    payload = build_payload(payload, workflow, previous_result)

    # In a real-world application, this would be a HTTP request and
    # we'd return :ok or :error based on the the response status.
    send(recipient, {url, payload})
    {:ok, workflow, nil}
  end

  defp build_payload(payload, workflow, previous_result) do
    payload
    |> Enum.map(fn {key, field} ->
      value = Demo.Command.get_field(field, workflow, previous_result)
      {key, value}
    end)
    |> Map.new()
  end
end
