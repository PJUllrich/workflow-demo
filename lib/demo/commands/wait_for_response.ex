defmodule Demo.Commands.WaitForResponse do
  @behaviour Demo.Command

  def execute(workflow, _params, _previous_result) do
    {:ok, workflow, :wait}
  end
end
