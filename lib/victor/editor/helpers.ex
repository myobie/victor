defmodule Victor.Editor.Helpers do
  @spec get_id(Path.t()) :: String.t()
  def get_id(path) do
    path
    |> Path.split()
    |> List.last()
  end
end
