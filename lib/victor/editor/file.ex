defmodule Victor.Editor.File do
  import Victor.Editor.Helpers

  defstruct id: nil, path: nil

  @type t :: %__MODULE__{id: String.t(), path: Path.t()}

  @spec new(Path.t()) :: t
  def new(path) do
    %__MODULE__{id: get_id(path), path: path}
  end
end
