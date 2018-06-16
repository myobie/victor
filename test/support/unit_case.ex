defmodule Victor.UnitCase do
  @moduledoc """
  This module is just a basic ExUnit.Case with some extra helpers
  """

  use ExUnit.CaseTemplate

  using(args) do
    quote do
      use ExUnit.Case, unquote(args)
      import ShorterMaps
      import Victor.TestHelper
    end
  end
end
