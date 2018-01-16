defmodule Victor.Editor.Section do
  alias Victor.Editor.Page

  @derive {Poison.Encoder, except: [:path, :errors]}
  defstruct id: nil, path: nil, sections: [], pages: [], errors: []

  @type id :: String.t()
  @type t :: %__MODULE__{
          id: id,
          path: Path.t(),
          sections: list(t),
          pages: list(Page.t()),
          errors: list(atom)
        }
  @type subcontents :: %{sections: list(t), pages: list(Page.t()), errors: list(atom)}

  require Logger
  import Victor.Editor.Helpers

  @spec find(list(t), id) :: t | nil
  def find(sections, id), do: Enum.find(sections, &(&1.id == id))

  @spec index(t) :: Page.t() | nil
  def index(section), do: page(section, "_index.md")

  @spec page(t, id) :: Page.t() | nil
  def page(%__MODULE__{pages: pages}, id), do: Enum.find(pages, &(&1.id == id))

  @spec from(Path.t()) :: t
  def from(path) do
    subcontents = scan(path)

    %__MODULE__{
      id: get_id(path),
      path: path,
      sections: subcontents.sections,
      pages: subcontents.pages,
      errors: subcontents.errors
    }
  end

  @spec scan(Path.t()) :: subcontents
  def scan(path) do
    Path.join(path, "*")
    |> Path.wildcard()
    |> process_paths(%{sections: [], pages: [], errors: []})
  end

  @spec process_paths(list(Path.t()), subcontents) :: subcontents
  defp process_paths([], %{sections: sections, pages: pages, errors: errors}) do
    %{
      sections: Enum.reverse(sections),
      pages: Enum.reverse(pages),
      errors: Enum.reverse(errors)
    }
  end

  defp process_paths([path | paths], acc) do
    cond do
      File.dir?(path) ->
        section = from(path)
        process_paths(paths, %{acc | sections: [section | acc.sections]})

      File.exists?(path) ->
        page = Page.from(path)
        process_paths(paths, %{acc | pages: [page | acc.pages]})

      true ->
        _ = Logger.debug("File not found: #{path}")
        process_paths(paths, %{acc | errors: [{path, :not_found} | acc.errors]})
    end
  end
end
