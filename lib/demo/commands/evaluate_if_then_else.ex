defmodule Demo.Commands.EvaluateIfThenElse do
  @behaviour Demo.Command

  @impl true
  def execute(workflow, condition, previous_result) do
    {path, comparison, expected_value} = condition.if
    value = Demo.Command.get_field(path, workflow, previous_result)

    case compare(value, comparison, expected_value) do
      true -> {:ok, workflow, condition.then}
      false -> {:ok, workflow, condition.else}
    end
  end

  defp compare(value, :equals, expected_value) do
    value == expected_value
  end

  defp compare(value, :greater_than_or_equal_to, expected_value) do
    value >= expected_value
  end
end
