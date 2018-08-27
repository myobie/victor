defmodule Victor.GitRemote do
  use Ecto.Schema

  import EctoEnum
  defenum(AdapterEnum, :git_remote_adapter_enum, [:vso, :github, :bitbucket])

  embedded_schema do
    field(:adapter, AdapterEnum)
    field(:url, :string)
  end

  @type t :: %__MODULE__{adapter: adapter_types, url: String.t()}

  alias Victor.GitRemote.{Missing, VSO, GitHub, Bitbucket}

  @type adapter_types :: :vso | :github | :bitbucket
  @type adapters :: Missing | VSO | GitHub | Bitbucket

  @spec adapter(adapter_types) :: adapters | no_return
  def adapter(type) do
    case type do
      :vso -> VSO
      :github -> GitHub
      :bitbucket -> Bitbucket
      _ -> Missing
    end
  end
end

defmodule Victor.GitRemote.Adapter do
  @type sha :: String.t()
  @type file :: %{type: String.t(), content: binary}
  @type files :: %{optional(String.t()) => file}

  @callback commit(files, sha) :: {:ok, sha} | {:error, atom}
end

defmodule Victor.GitRemote.Missing do
  @behaviour Victor.GitRemote.Adapter

  def commit(_files, _sha), do: {:error, :missing_git_remote_adapter_config}
end

defmodule Victor.GitRemote.GitHub do
  @behaviour Victor.GitRemote.Adapter

  def commit(_files, _sha), do: {:error, :github_not_available}
end

defmodule Victor.GitRemote.Bitbucket do
  @behaviour Victor.GitRemote.Adapter

  def commit(_files, _sha), do: {:error, :bitbucket_not_available}
end
