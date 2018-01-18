defmodule Victor.Editor do
  alias Victor.{GitRepo, Website}
  alias Victor.Editor.Section

  @spec content(Website.t()) :: {:ok, list(Section.t())} | {:error, list(term)}
  def content(site) do
    case Section.scan(GitRepo.content_path(site.git_repo)) do
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
