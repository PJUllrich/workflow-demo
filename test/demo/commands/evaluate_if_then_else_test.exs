defmodule Demo.Commands.EvaluateIfThenElseTest do
  use ExUnit.Case, async: true

  alias Demo.Commands.EvaluateIfThenElse

  describe "execute/3" do
    test "returns the success value if the condition is true" do
      condition = %{
        if: {["previous", "decision"], :equals, "process"},
        then: :continue,
        else: :abort
      }

      previous_result = %{"decision" => "process"}

      assert {:ok, _workflow, :continue} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)
    end

    test "returns the failure value if the condition is false" do
      condition = %{
        if: {["previous", "decision"], :equals, "ignore"},
        then: :continue,
        else: :abort
      }

      previous_result = %{"decision" => "process"}
      assert {:ok, nil, :abort} = EvaluateIfThenElse.execute(nil, condition, previous_result)
    end
  end

  describe "comparisons" do
    test "equals" do
      condition = %{
        if: {["previous", "amount"], :equals, 100},
        then: :continue,
        else: :abort
      }

      previous_result = %{"amount" => 100}

      assert {:ok, _workflow, :continue} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)

      previous_result = %{"amount" => 99}

      assert {:ok, _workflow, :abort} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)
    end

    test "greater_than_or_equal_to" do
      condition = %{
        if: {["previous", "amount"], :greater_than_or_equal_to, 100},
        then: :continue,
        else: :abort
      }

      previous_result = %{"amount" => 100}

      assert {:ok, _workflow, :continue} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)

      previous_result = %{"amount" => 101}

      assert {:ok, _workflow, :continue} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)

      previous_result = %{"amount" => 99}

      assert {:ok, _workflow, :abort} =
               EvaluateIfThenElse.execute(nil, condition, previous_result)
    end
  end
end
