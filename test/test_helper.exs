ExUnit.start()

defmodule Victor.TestHelper do
  defmacro disable_logs(do: block) do
    quote do
      :ok = Logger.disable(self())
      result = unquote(block)
      :ok = Logger.enable(self())
      result
    end
  end
end
