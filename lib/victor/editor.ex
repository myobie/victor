defmodule Victor.Editor do
  alias Victor.Hugo
  alias Victor.Editor.Section

  @spec content :: {:ok, list(Section.t())} | {:error, list(term)}
  def content do
    case Section.scan(Hugo.content_path()) do
      %{errors: [], sections: sections, pages: []} ->
        {:ok, sections}

      %{errors: errors, pages: [_, _]} ->
        # NOTE: Should we care?
        {:error, [:top_level_content_pages | errors]}

      %{errors: errors} ->
        {:error, errors}
    end
  end
end
