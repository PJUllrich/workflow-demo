defmodule Demo.Commands.ParseHTTPRequestTest do
  use ExUnit.Case

  alias Demo.Commands.ParseHTTPRequest

  test "returns the predefined body parameters" do
    request_body = %{"decision" => "process", "foo" => "ignore"}

    {:ok, _workflow, result} =
      ParseHTTPRequest.execute(nil, %{take_params: ["decision"]}, request_body)

    assert result == %{"decision" => "process"}
  end
end
