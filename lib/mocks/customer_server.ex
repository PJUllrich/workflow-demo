defmodule Mocks.CustomerServer do
  @moduledoc """
  A Mock server that simulates a customer server that receives webhook events
  from our application and responds to it.
  """
  use GenServer

  require Logger

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    {:ok, :initial_state}
  end

  def handle_info({"https://client-server.com/review", %{"workflow_id" => workflow_id}}, state) do
    Logger.debug("Customer Server: Received a Review Request for Workflow #{workflow_id}")
    schedule_review_response(workflow_id)
    {:noreply, state}
  end

  def handle_info(
        {"https://client-server.com/pay-invoice", %{"amount" => amount, "iban" => iban}},
        state
      ) do
    Logger.debug(
      "Customer Server: Received an Invoice Pay Request over #{amount} to #{iban} \n\n"
    )

    {:noreply, state}
  end

  def handle_info({:send_response, workflow_id}, state) do
    decision = "process"

    Logger.debug(
      "Customer Server: Sending Response for Review Decision for Workflow: #{workflow_id} - #{decision}"
    )

    params = {:post, :review_response, %{"workflow_id" => workflow_id, "decision" => "process"}}
    send(DemoWeb.Controller, params)

    {:noreply, state}
  end

  defp schedule_review_response(workflow_id) do
    Process.send_after(__MODULE__, {:send_response, workflow_id}, 2_000)
  end
end
