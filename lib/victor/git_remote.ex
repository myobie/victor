defmodule Victor.GitRemote do
  @type sha :: String.t
  @type file :: %{type: String.t, content: binary}
  @type files :: %{optional(String.t) => file}

  @callback commit(files, sha) :: {:ok, sha} | {:error, atom}

  @config Application.get_env(:victor, :git, [])
  @adapter_type Keyword.get(@config, :adapter, :missing)

  alias Victor.GitRemote.{Missing, VSO, GitHub, Bitbucket}

  @type adapter_types :: :missing | :vso | :github | :bitbucket
  @type adapters :: Missing | VSO | GitHub | Bitbucket

  @spec adapter :: adapters | no_return
  @spec adapter(adapter_types) :: adapters | no_return
  def adapter, do: adapter(@adapter_type)

  def adapter(type) do
    case type do
      :missing -> Missing
      :vso -> VSO
      :github -> GitHub
      :bitbucket -> Bitbucket
      _ -> raise "Invalid git adapter type in config"
    end
  end
end

defmodule Victor.GitRemote.Missing do
  @behaviour Victor.GitRemote

  def commit(_files, _sha), do: {:error, :missing_git_remote_adapter_config}
end

defmodule Victor.GitRemote.GitHub do
  @behaviour Victor.GitRemote

  def commit(_files, _sha), do: {:error, :github_not_available}
end

defmodule Victor.GitRemote.Bitbucket do
  @behaviour Victor.GitRemote

  def commit(_files, _sha), do: {:error, :bitbucket_not_available}
end
