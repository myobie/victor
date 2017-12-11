defmodule Victor.Editor.Helpers do
  def get_id(path) do
    path
    |> Path.split()
    |> List.last()
  end
end
