defmodule Victor.Editor do
  alias Victor.{GitRepo, Website}
  alias Victor.Editor.Content

  @spec content(Website.t()) :: {:ok, Content.t()} | {:error, term}
  def content(site), do: Content.scan(GitRepo.content_path(site.repo))
end
