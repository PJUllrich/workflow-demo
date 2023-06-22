defmodule Mocks.DocumentProducer do
  @moduledoc """
  This module simulates incoming documents.

  It generates a new PDF document in a given time interval and sends it
  to the document handler. This module could be an API
  controller that receives HTTP requests from customers.
  """
  use GenServer

  alias Demo.Workflows.Document

  # The Interval with which this Producer generates new random documents
  @interval :timer.seconds(10)

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    schedule_new_document()
    generate_document()
    {:ok, :initial_state}
  end

  def handle_info(:generate_document, state) do
    schedule_new_document()
    generate_document()

    {:noreply, state}
  end

  defp generate_document() do
    document = random_document()
    send(DemoWeb.Controller, {:post, :new_document, document})
  end

  defp schedule_new_document() do
    Process.send_after(self(), :generate_document, @interval)
  end

  defp random_document() do
    %Document{filename: "file-#{Enum.random(1..1000)}.pdf", type: "application/pdf"}
  end
end
