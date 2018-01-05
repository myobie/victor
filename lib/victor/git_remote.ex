defmodule Victor.GitRemote do
  @type sha :: String.t
  @type file :: %{type: String.t, content: binary}
  @type files :: %{optional(String.t) => file}

  @callback commit(files) :: {:ok, sha} | {:error, atom}

  @config Application.get_env(:victor, :git, [])
  @adapter Keyword.get(@config, :adapter, Victor.MissingGitRemote)

  @spec adapter :: __MODULE__
  def adapter, do: @adapter
end

defmodule Victor.MissingGitRemote do
  @behaviour Victor.GitRemote

  def commit(_files), do: {:error, :missing_git_remote_adapter_config}
end
