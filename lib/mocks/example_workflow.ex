defmodule Mocks.ExampleWorkflow do
  @moduledoc """
  An example workflow with multiple sync and async commands.

  This example workflow could have been created by a customer
  in e.g. a workflow builder UI and could be persisted in a Postgres database.
  """

  alias Demo.Workflows.Workflow
  alias Demo.Command

  alias Demo.Commands.SendWebhookEvent
  alias Demo.Commands.ParseHTTPRequest
  alias Demo.Commands.ParseDocument
  alias Demo.Commands.EvaluateIfThenElse
  alias Demo.Commands.WaitForResponse

  def new(document) do
    document
    |> new_workflow()
    |> put_steps()
  end

  defp new_workflow(document) do
    %Workflow{id: UUID.uuid4(), document: document}
  end

  defp put_steps(workflow) do
    steps = [
      %Command{
        position: 0,
        module: SendWebhookEvent,
        params: %{
          url: "https://client-server.com/review",
          payload: %{"workflow_id" => ["workflow", "id"], "filename" => ["document", "filename"]}
        }
      },
      %Command{position: 1, module: WaitForResponse, params: %{}},
      %Command{position: 2, module: ParseHTTPRequest, params: %{take_params: ["decision"]}},
      %Command{
        position: 3,
        module: EvaluateIfThenElse,
        params: %{
          if: {["previous", "decision"], :equals, "process"},
          then: :continue,
          else: :abort
        }
      },
      %Command{position: 4, module: ParseDocument, params: %{}},
      %Command{
        position: 5,
        module: SendWebhookEvent,
        params: %{
          url: "https://client-server.com/pay-invoice",
          payload: %{
            "amount" => ["document", "parsed_content", "amount"],
            "iban" => ["document", "parsed_content", "iban"]
          }
        }
      }
    ]

    Map.put(workflow, :steps, steps)
  end
end
