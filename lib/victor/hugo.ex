defmodule Victor.Hugo do
  @config Application.get_env(:victor, :hugo)
  @path Keyword.get(@config, :path)
  @rev_parse_args ~w(rev-parse --verify HEAD)

  @type sha :: String.t()
  @type command_result :: {:ok, String.t()} | {:error, String.t()}

  @spec repo_path(sha) :: Path.t()
  def repo_path(version \\ "current"), do: Path.join([@path, "versions", version])

  @spec content_path(sha) :: Path.t()
  def content_path(version \\ "current"), do: Path.join([repo_path(version), "content"])

  @spec public_path(sha) :: Path.t()
  def public_path(version \\ "current"), do: Path.join([repo_path(version), "public"])

  defp initial_setup_sh, do: Application.app_dir(:victor, "priv/initial-setup.sh")
  defp deploy_sh, do: Application.app_dir(:victor, "priv/deploy.sh")
  defp endpoint_url, do: VictorWeb.Endpoint.url()

  @spec initial_setup(String.t()) :: command_result
  def initial_setup(url) do
    case System.cmd(initial_setup_sh(), [@path, url], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  @spec deploy(sha) :: command_result
  def deploy(rev \\ "master") do
    case System.cmd(deploy_sh(), [@path, rev, endpoint_url()], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  @spec current_rev :: command_result
  def current_rev do
    case System.cmd("git", @rev_parse_args, cd: repo_path()) do
      {output, 0} -> {:ok, String.trim(output)}
      {output, _} -> {:error, output}
    end
  end
end
