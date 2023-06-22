defmodule Support.ConcurrencyHelper do
  def wait_until(fun), do: wait_until(500, fun)

  def wait_until(0, fun), do: fun.()

  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      ExUnit.AssertionError ->
        :timer.sleep(100)
        wait_until(max(0, timeout - 100), fun)
    end
  end

  def sleep(session, how_long_in_milliseconds \\ 500) do
    :timer.sleep(how_long_in_milliseconds)
    session
  end
end
