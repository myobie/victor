defmodule Victor.GitRepo do
  use Ecto.Schema

  embedded_schema do
    field(:path, :string)
  end

  @type t :: %__MODULE__{path: Path.t()}
  @type sha :: String.t()

  @spec repo_path(t) :: Path.t()
  def repo_path(repo), do: Path.join([repo.path, "repo"])

  @spec path(t) :: Path.t()
  @spec path(t, sha) :: Path.t()
  @spec path(t, sha, [Path.t()]) :: Path.t()
  def path(repo, version \\ "current", additional_segments \\ []),
    do: Path.join([repo.path, "versions", version] ++ additional_segments)

  @spec content_path(t) :: Path.t()
  @spec content_path(t, sha) :: Path.t()
  def content_path(repo, version \\ "current"), do: path(repo, version, ["content"])

  @spec public_path(t) :: Path.t()
  @spec public_path(t, sha) :: Path.t()
  def public_path(repo, version \\ "current"), do: path(repo, version, ["public"])
end
