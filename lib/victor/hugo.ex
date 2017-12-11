defmodule Victor.Hugo do
  @config Application.get_env(:victor, :hugo)
  @url Keyword.get(@config, :url)
  @path Keyword.get(@config, :path)

  def repo_path, do: Path.join([@path, "versions", "current"])
  def content_path, do: Path.join([repo_path(), "content"])
  def public_path, do: Path.join([repo_path(), "public"])

  defp initial_setup_sh, do: Application.app_dir(:victor, "priv/initial-setup.sh")
  defp deploy_sh, do: Application.app_dir(:victor, "priv/deploy.sh")
  defp endpoint_url, do: VictorWeb.Endpoint.url()

  def initial_setup do
    case System.cmd(initial_setup_sh(), [@path, @url], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  def deploy(rev \\ "master") do
    case System.cmd(deploy_sh(), [@path, rev, endpoint_url()], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end
end
