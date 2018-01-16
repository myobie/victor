defmodule Victor.Editor.Section do
  alias Victor.Editor.Content

  @derive {Poison.Encoder, except: [:path, :errors]}
  defstruct id: nil, path: nil, index: %Content{}, subsections: [], pages: [], errors: []

  require Logger
  import Victor.Editor.Helpers

  def find(sections, id), do: Enum.find(sections, &(&1.id == id))

  def page(%__MODULE__{pages: pages}, id), do: Enum.find(pages, &(&1.id == id))

  def title(%__MODULE__{} = section), do: Content.title(section.index)

  def from(path) do
    subcontents = scan(path)

    %__MODULE__{
      id: get_id(path),
      path: path,
      index: Content.from(Path.join(path, "_index.md")),
      subsections: subcontents.sections,
      pages: subcontents.pages,
      errors: subcontents.errors
    }
  end

  def scan(path) do
    Path.join(path, "*")
    |> Path.wildcard()
    |> process_paths(%{sections: [], pages: [], errors: []})
  end

  defp process_paths([], %{sections: sections, pages: pages, errors: errors}) do
    %{
      sections: Enum.reverse(sections),
      pages: Enum.reverse(pages),
      errors: Enum.reverse(errors)
    }
  end

  defp process_paths([path | paths], acc) do
    cond do
      get_id(path) == "_index.md" ->
        process_paths(paths, acc)

      File.dir?(path) ->
        section = from(path)
        process_paths(paths, %{acc | sections: [section | acc.sections]})

      File.exists?(path) ->
        page = Content.from(path)
        process_paths(paths, %{acc | pages: [page | acc.pages]})

      true ->
        _ = Logger.debug("File not found: #{path}")
        process_paths(paths, %{acc | errors: [{path, :not_found} | acc.errors]})
    end
  end
end
