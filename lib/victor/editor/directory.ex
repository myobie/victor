defmodule Victor.Editor.Directory do
  defstruct path: nil, children: []

  @type t :: %__MODULE__{
          path: Path.t(),
          children: list(Directory.t() | Victor.Editor.File.t())
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
end
