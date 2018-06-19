defmodule Victor.Editor.Directory do
  import Victor.Editor.Helpers

  defstruct id: nil, path: nil, children: []

  @type t :: %__MODULE__{
          id: String.t(),
          path: Path.t(),
          children: list(t | Victor.Editor.File.t())
        }

  # A directory is a section if:
  # * it contains an _index.md
  # * a sub-directory of it contains an _index.md
  #
  # _The root directory is never a section._
  #
  # A directory is a page if:
  # * it is the root directory and contains an _index.md
  # * it contains an index.md
  #
  # _A directory that is a sub-directory of a page is never a section._

  @spec new(Path.t()) :: t
  def new(path) do
    %__MODULE__{id: get_id(path), path: path}
  end
end
