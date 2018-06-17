defmodule Victor.Editor.Content do
  require Logger
  alias Victor.Editor
  alias Editor.{Directory, Markdown, Section, Page}
  import Editor.Helpers

  @derive {Poison.Encoder, except: []}
  defstruct markdown: nil, sections: [], pages: [], resources: [], children: []

  # The root directory represents the homepage if it directly contains an _index.md. If not, then the markdown is nil.
  #
  # Sections are sub-directoies that are themselves sections.
  #
  # Pages are files or sub-directories that are themselves pages.
  #
  # Resources are only files. Directories under the root directory are either sections or simply copied over to the public website as-is.
  #
  # Children is a list of those directories that are not sections.

  @type t :: %__MODULE__{
          markdown: Markdown.t() | nil,
          sections: list(Section.t()),
          pages: list(Page.t()),
          resources: list(Editor.File.t()),
          children: list(Directory.t())
        }

  @spec scan(Path.t()) :: {:ok, t} | {:error, term}
  def scan(path) do
    process_paths(ls(path), %__MODULE__{})
  end

  @spec scan_directory(Path.t(), t | Section.t() | Directory.t() | Page.t()) ::
          {:ok, t | Section.t() | Directory.t() | Page.t()} | {:error, term}

  defp scan_directory(path, %__MODULE__{} = content) do
    case process_paths(ls(path), %Directory{path: path}) do
      {:ok, %Section{} = subsection} -> prepend_to_sections(content, subsection)
      {:ok, %Page{} = page} -> prepend_to_pages(content, page)
      {:ok, %Directory{} = dir} -> prepend_to_children(content, dir)
      {:error, error} -> {:error, error}
    end
  end

  defp scan_directory(path, %Section{} = section) do
    case process_paths(ls(path), %Directory{path: path}) do
      {:ok, %Section{} = subsection} -> prepend_to_sections(section, subsection)
      {:ok, %Page{} = page} -> prepend_to_pages(section, page)
      {:ok, %Directory{} = dir} -> prepend_to_invalid(section, dir)
      {:error, error} -> {:error, error}
    end
  end

  defp scan_directory(path, %Directory{} = directory) do
    case process_paths(ls(path), %Directory{path: path}) do
      {:ok, %Section{} = subsection} ->
        # convert me to a section since I contain a section
        section = convert_directory_to_section(directory)
        # and this subpath is a subsection
        prepend_to_sections(section, subsection)

      {:ok, %Directory{} = subdirectory} ->
        prepend_to_children(directory, subdirectory)

      {:ok, %Page{} = page} ->
        prepend_to_children(directory, page)

      {:error, error} ->
        {:error, error}
    end
  end

  defp scan_directory(path, %Page{} = page) do
    with {:ok, dir} <- slurp(ls(path), %Directory{path: path}) do
      prepend_to_resources(page, dir)
    end
  end

  defp convert_directory_to_section(dir) do
    {sections, pages, resources, invalid} =
      Enum.reduce(dir.children, {[], [], [], []}, fn
        %Section{} = item, {s, p, r, i} -> {[item | s], p, r, i}
        %Page{} = item, {s, p, r, i} -> {s, [item | p], r, i}
        %Editor.File{} = item, {s, p, r, i} -> {s, p, [item | r], i}
        %Directory{} = item, {s, p, r, i} -> {s, p, r, [item | i]}
      end)

    %Section{
      id: get_id(dir.path),
      path: dir.path,
      sections: sections,
      pages: pages,
      resources: resources,
      invalid: invalid
    }
  end

  @spec scan_file(Path.t(), t | Section.t() | Directory.t() | Page.t()) ::
          {:ok, t | Section.t() | Directory.t() | Page.t()} | {:error, term}

  defp scan_file(path, %__MODULE__{} = content), do: scan_file_for_section(path, content)
  defp scan_file(path, %Section{} = section), do: scan_file_for_section(path, section)

  defp scan_file(path, %Directory{} = dir) do
    case {path |> Path.rootname() |> Path.basename(), page?(path)} do
      {"_index", true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          section = convert_directory_to_section(dir)
          {:ok, Map.put(section, :markdown, markdown)}
        end

      {"index", true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          page = %Page{id: get_id(dir.path), path: dir.path, markdown: markdown}
          # convert to a page by copying children over to resources
          {:ok, Map.put(page, :resources, dir.children)}

          # TODO: if any of the old dir children are pages, they need to be converted back to directories since hugo does not allow nested page bundles
        end

      {_, true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          page = %Page{id: get_id(path), path: path, markdown: markdown}
          prepend_to_children(dir, page)
        end

      {_, _} ->
        prepend_to_children(dir, %Editor.File{path: path})
    end
  end

  defp scan_file(path, %Page{} = page) do
    case {path |> Path.rootname() |> Path.basename(path), page?(path)} do
      {"index", true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          page = %{page | markdown: markdown}
          {:ok, page}
        end

      _ ->
        prepend_to_resources(page, %Editor.File{path: path})
    end
  end

  @spec scan_file_for_section(Path.t(), t | Section.t()) ::
          {:ok, t | Section.t()} | {:error, term}
  defp scan_file_for_section(path, acc) do
    case {path |> Path.rootname() |> Path.basename(path), page?(path)} do
      {"_index", true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          {:ok, Map.put(acc, :markdown, markdown)}
        end

      {_, true} ->
        with {:ok, markdown} <- Markdown.parse(path) do
          page = %Page{id: get_id(path), path: path, markdown: markdown}
          prepend_to_pages(acc, page)
        end

      {_, _} ->
        prepend_to_resources(acc, %Editor.File{path: path})
    end
  end

  @spec ls(Path.t()) :: list(Path.t())
  defp ls(path) when is_binary(path) do
    path
    |> Path.join("*")
    |> Path.wildcard()
    |> Enum.reverse()
  end

  @spec slurp(list(Path.t()), Directory.t()) :: {:ok, Directory.t()} | {:error, term}

  defp slurp([], %Directory{} = dir) do
    {:ok, dir}
  end

  defp slurp([path | paths], %Directory{} = dir) do
    cond do
      String.ends_with?(path, "/index.md") ->
        # skip the index.md file when slurping up a pages resources
        slurp(paths, dir)

      File.dir?(path) ->
        with {:ok, subdir} <- slurp(ls(path), %Directory{path: path}),
             {:ok, dir} = prepend_to_children(dir, subdir) do
          slurp(paths, dir)
        end

      File.exists?(path) ->
        {:ok, dir} = prepend_to_children(dir, %Editor.File{path: path})
        slurp(paths, dir)

      true ->
        _ = Logger.error("File disappeared during content scan: #{path}")
        {:error, :file_disappeared}
    end
  end

  @spec process_paths(list(Path.t()), t | Section.t() | Directory.t() | Page.t()) ::
          {:ok, t | Section.t() | Directory.t() | Page.t()} | {:error, term}

  defp process_paths([], dir) do
    {:ok, dir}
  end

  defp process_paths([path | paths], acc) do
    cond do
      File.dir?(path) ->
        with {:ok, acc} <- scan_directory(path, acc) do
          process_paths(paths, acc)
        end

      File.exists?(path) ->
        with {:ok, acc} <- scan_file(path, acc) do
          process_paths(paths, acc)
        end

      true ->
        _ = Logger.error("File disappeared during content scan: #{path}")
        {:error, :file_disappeared}
    end
  end

  # Found list of extensions at https://github.com/gohugoio/hugo/blob/80230f26a3020ff33bac2bef01b2c0e314b89f86/helpers/general.go#L77-L91
  @page_extenions ~w(md markdown mdown asciidoc adoc ad mmark rst pandoc html htm org)
                  |> Enum.map(&".#{&1}")

  @spec page?(Path.t()) :: boolean
  defp page?(path) do
    Enum.member?(@page_extenions, Path.extname(path))
  end

  @spec prepend_to_sections(t | Section.t(), Section.t()) :: {:ok, t | Section.t()}
  defp prepend_to_sections(acc, section) do
    acc = %{acc | sections: [section | acc.sections]}
    {:ok, acc}
  end

  @spec prepend_to_pages(t | Section.t(), Page.t()) :: {:ok, t | Section.t()}
  defp prepend_to_pages(acc, page) do
    acc = %{acc | pages: [page | acc.pages]}
    {:ok, acc}
  end

  @spec prepend_to_resources(t | Section.t() | Page.t(), Editor.File.t() | Directory.t()) ::
          {:ok, t | Section.t() | Page.t()}
  defp prepend_to_resources(acc, item) do
    acc = %{acc | resources: [item | acc.resources]}
    {:ok, acc}
  end

  @spec prepend_to_children(t | Directory.t(), Editor.File.t() | Directory.t()) ::
          {:ok, t | Directory.t()}
  defp prepend_to_children(acc, item) do
    acc = %{acc | children: [item | acc.children]}
    {:ok, acc}
  end

  @spec prepend_to_invalid(Section.t(), Directory.t()) :: {:ok, Section.t()}
  defp prepend_to_invalid(section, dir) do
    section = %{section | invalid: [dir | section.invalid]}
    {:ok, section}
  end
end
