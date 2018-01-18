defmodule Victor.Website do
  defstruct host: nil, scheme: "https:", git_repo: %Victor.GitRepo{}

  @type t :: %__MODULE__{host: String.t(), git_repo: Victor.GitRepo.t()}

  @spec url(t) :: String.t()
  def url(website) do
    "#{website.scheme}//#{website.host}/"
  end
end

