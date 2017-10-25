defmodule Victor.Hugo do
  @config Application.get_env(:victor, :hugo)
  @url Keyword.get(@config, :url)
  @path Keyword.get(@config, :path)

  def public_path, do: Path.join([@path, "versions", "current", "public"])

  @initial_setup_sh Path.expand("./priv/initial-setup.sh")
  @deploy_sh Path.expand("./priv/deploy.sh")

  def initial_setup do
    case System.cmd(@initial_setup_sh, [@path, @url], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  def deploy(rev \\ "master") do
    base_url = VictorWeb.Endpoint.url()
    case System.cmd(@deploy_sh, [@path, rev, base_url], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end
end
