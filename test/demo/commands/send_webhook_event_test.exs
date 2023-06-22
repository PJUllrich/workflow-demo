defmodule Demo.Commands.SendWebhookEventTest do
  use ExUnit.Case, async: true

  alias Demo.Workflows.Workflow
  alias Demo.Workflows.Document
  alias Demo.Commands.SendWebhookEvent

  test "sends a request with the correct payload" do
    document = %Document{filename: "file.pdf"}
    workflow = %Workflow{document: document}
    params = %{url: "/test", payload: %{"filename" => ["document", "filename"]}}

    assert {:ok, _workflow, _map} = SendWebhookEvent.execute(workflow, params, nil, self())
    assert_receive {"/test", %{"filename" => "file.pdf"}}
  end

  test "sends a request with a field from the previous result" do
    document = %Document{filename: "file.pdf"}
    workflow = %Workflow{document: document}
    params = %{url: "/test", payload: %{"result" => ["previous", "decision"]}}

    assert {:ok, _workflow, _map} =
             SendWebhookEvent.execute(workflow, params, %{"decision" => "process"}, self())

    assert_receive {"/test", %{"result" => "process"}}
  end
end
