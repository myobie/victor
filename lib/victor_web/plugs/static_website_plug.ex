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

  defp join([]), do: ""
  defp join(paths), do: Path.join(paths)

  defp serve(conn, path) do
    if File.dir?(path) do
      serve(conn, join([path, "index.html"]))
    else
      if File.exists?(path) do
        serve_file(conn, path)
      else
        conn
      end
    end
  end

  defp mime(path) do
    "." <> ext = Path.extname(path)
    MIME.type(ext)
  end

  defp serve_file(conn, path) do
    conn
    |> put_resp_content_type(mime(path))
    |> send_file(200, path)
    |> halt()
  end
end
