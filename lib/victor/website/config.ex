defmodule Victor.Website.Config do
  @spec parse(map) :: Victor.Website.t()
  def parse(config) do
    %Victor.Website{
      host: config.host,
      repo: parse_repo_config(config.repo),
      remote: parse_remote_config(config.remote)
    }
    |> parse_scheme_if_present(config)
    |> parse_authentication_if_present(config)
  end

  defp parse_repo_config(path) when is_binary(path) do
    %Victor.GitRepo{path: Path.expand(path)}
  end

  defp parse_repo_config(repo_config) do
    %Victor.GitRepo{path: Path.expand(repo_config.path)}
  end

  defp parse_remote_config(url) when is_binary(url) do
    %Victor.GitRemote{url: url, adapter: git_remote_adapter_from_url(url)}
  end

  defp parse_remote_config(remote_config) do
    %Victor.GitRemote{url: remote_config.url, adapter: remote_config.adapter}
  end

  defp git_remote_adapter_from_url(url) do
    cond do
      String.contains?(url, "visualstudio.com") -> :vso
      String.contains?(url, "github.com") -> :github
      String.contains?(url, "bitbucket.org") -> :bitbucket
      true -> :missing
    end
  end

  defp parse_scheme_if_present(site, config) do
    if Map.has_key?(config, :scheme) do
      Map.put(site, :scheme, config.scheme)
    else
      site
    end
  end

  defp parse_authentication_if_present(site, config) do
    if Map.has_key?(config, :authentication) do
      Map.put(site, :authentication, %Victor.AuthenticationConfig{
        visitor_authorize_uri: config.authentication.visitor_authorize_uri,
        editor_authorize_uri: config.authentication.editor_authorize_uri,
        client_id: config.authentication.client_id,
        redirect_uri: config.authentication.redirect_uri,
        public_key: config.authentication.public_key,
        verifiers: parse_authentication_verifiers(config.authentication.verifiers)
      })
    else
      site
    end
  end

  defp parse_authentication_verifiers(verifiers) do
    parse_authentication_verifiers([], verifiers)
  end

  defp parse_authentication_verifiers(results, []), do: results

  defp parse_authentication_verifiers(results, [%{type: type, content: content} | rest]) do
    verifier = %Victor.AuthenticationConfig.Verifier{type: type, content: content}
    parse_authentication_verifiers([verifier | results], rest)
  end

  defp parse_authentication_verifiers(results, [:everyone | rest]) do
    verifier = %Victor.AuthenticationConfig.Verifier{type: :everyone}
    parse_authentication_verifiers([verifier | results], rest)
  end

  defp parse_authentication_verifiers(results, [{type, content} | rest]) when is_atom(type) do
    verifier = %Victor.AuthenticationConfig.Verifier{type: type, content: content}
    parse_authentication_verifiers([verifier | results], rest)
  end
end
