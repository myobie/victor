defmodule Victor.Hugo do
  alias Victor.{GitRepo, Website}

  @rev_parse_args ~w(rev-parse --verify HEAD)

  @type command_result :: {:ok, String.t()} | {:error, String.t()}
  @type sha :: Victor.GitRepo.sha()

  defp initial_setup_sh, do: Application.app_dir(:victor, "priv/initial-setup.sh")
  defp build_sh, do: Application.app_dir(:victor, "priv/build.sh")

  @spec initial_setup(Website.t()) :: command_result
  def initial_setup(site) do
    case System.cmd(initial_setup_sh(), [site.git_repo.path, Website.url(site)], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  @spec build(Website.t, sha) :: command_result
  def build(site, rev \\ "master") do
    case System.cmd(build_sh(), [site.git_repo.path, rev, Website.url(site)], stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  @spec current_rev(Website.t) :: command_result
  def current_rev(site) do
    case System.cmd("git", @rev_parse_args, cd: GitRepo.path(site.git_repo)) do
      {output, 0} -> {:ok, String.trim(output)}
      {output, _} -> {:error, output}
    end
  end
end
