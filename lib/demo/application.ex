defmodule Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = children(Mix.env())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:test), do: []

  defp children(_env) do
    [
      DemoWeb.Controller,
      Mocks.CustomerServer,
      Demo.Workflows,
      Demo.Engine,
      Mocks.DocumentProducer
    ]
  end
end
