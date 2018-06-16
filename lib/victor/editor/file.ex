defmodule Victor.Editor.File do
  defstruct path: nil
  @type t :: %__MODULE__{path: Path.t()}
end
