defmodule Victor.Website do
  defstruct host: nil,
            scheme: "https:",
            repo: %Victor.GitRepo{},
            remote: %Victor.GitRemote{},
            authentication: nil

  @type t :: %__MODULE__{host: String.t(), repo: Victor.GitRepo.t(), remote: Victor.GitRemote.t()}

  @spec url(t) :: String.t()
  def url(website) do
    "#{website.scheme}//#{website.host}/"
  end
end

