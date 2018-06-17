defmodule Victor.Editor.Page do
  @derive {Poison.Encoder, except: [:path]}
  defstruct id: nil, path: nil, markdown: nil, resources: []

  # A page can created from either a file or a directory (also known as a page bundle).
  #
  # The markdown of a page either comes from itself (a file) or an index.md file directly in it's directory.
  #
  # Resources are either files or sub-directories.
  #
  # A sub-directory of a page bundle cannot be a section.

  require Logger
  alias Victor.Editor
  alias Editor.{Directory, Markdown}

  @type fields :: %{optional(String.t()) => String.t()}
  @type t :: %__MODULE__{
          id: String.t(),
          path: Path.t(),
          markdown: Markdown.t(),
          resources: list(Directory.t() | Editor.File.t())
        }

  @spec get(t, String.t()) :: String.t() | nil
  def get(%__MODULE__{markdown: %{frontmatter: tm}}, field), do: Map.get(tm, field)

  @spec fetch(t, String.t()) :: {:ok, String.t()} | :error
  def fetch(%__MODULE__{markdown: %{frontmatter: tm}}, field), do: Map.fetch(tm, field)

  @spec title(t) :: String.t() | nil
  def title(%__MODULE__{} = content), do: get(content, "title")
end
