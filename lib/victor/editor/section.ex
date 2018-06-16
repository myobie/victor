defmodule Victor.Editor.Section do
  require Logger
  alias Victor.Editor
  alias Editor.{Markdown, Page, Directory}

  @derive {Poison.Encoder, except: [:path]}
  defstruct id: nil, path: nil, markdown: nil, sections: [], pages: [], resources: [], invalid: []

  # A section is always also a directory.
  # (A directory is only a section if it or a sub-directory of itself contains an _index.md file.)
  #
  # The markdown of a section comes from an _index.md file directly in it's directory. It is possible to not have an _index.md file in a section, so in that case the markdown is nil.
  #
  # Sections are sub-directories that are also themselves sections.
  #
  # Pages are files or sub-directoies that are also themselves pages.
  #
  # Resources are only files. Directories under a section are either sections themselves or just other files that are not going to be included in the final website build.
  #
  # Invalid is a collection of all the sub-directories of this section that are not themselves a section and are therefore not copied over to the public site at all and are inaccessible.

  @type id :: String.t()
  @type t :: %__MODULE__{
          id: id,
          path: Path.t(),
          markdown: Markdown.t() | nil,
          sections: list(t),
          pages: list(Page.t()),
          resources: list(Editor.File.t()),
          invalid: list(Directory.t())
        }

  @spec find(list(t), id) :: t | nil
  def find(sections, id), do: Enum.find(sections, &(&1.id == id))

  @spec index(t) :: Page.t() | nil
  def index(section), do: page(section, "_index.md")

  @spec page(t, id) :: Page.t() | nil
  def page(%__MODULE__{pages: pages}, id), do: Enum.find(pages, &(&1.id == id))

  @spec get(t, String.t()) :: String.t() | nil
  def get(%__MODULE__{markdown: %{frontmatter: tm}}, field), do: Map.get(tm, field)

  @spec fetch(t, String.t()) :: {:ok, String.t()} | :error
  def fetch(%__MODULE__{markdown: %{frontmatter: tm}}, field), do: Map.fetch(tm, field)

  @spec title(t) :: String.t() | nil
  def title(%__MODULE__{} = content), do: get(content, "title")
end
