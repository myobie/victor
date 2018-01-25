defmodule VictorWeb.StaticWebsitePlug do
  @behaviour Plug
  import Plug.Conn

  def init(default), do: default

  def call(%{assigns: %{website: website}} = conn, _) do
    public_path = Victor.GitRepo.public_path(website.repo)
    url_path = join(conn.path_info)
    serve(conn, join([public_path, url_path]))
  end

  def call(conn, _), do: conn

  @spec join(list(String.t())) :: String.t()
  defp join([]), do: ""
  defp join(paths), do: Path.join(paths)

  @spec serve(Plug.Conn.t(), Path.t()) :: Plug.Conn.t()
  defp serve(conn, path) do
    cond do
      File.dir?(path) -> serve(conn, join([path, "index.html"]))
      File.exists?(path) -> serve_file(conn, path)
      true -> conn
    end
  end

  @spec mime(Path.t()) :: String.t()
  defp mime(path) do
    "." <> ext = Path.extname(path)
    MIME.type(ext)
  end

  @spec serve_file(Plug.Conn.t(), Path.t()) :: Plug.Conn.t()
  defp serve_file(conn, path) do
    conn
    |> put_resp_content_type(mime(path))
    |> send_file(200, path)
    |> halt()
  end
end
