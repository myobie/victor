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
    case get_req_header(conn, "range") do
      [range] -> serve_range(conn, path, range)
      _ -> serve_entire_file(conn, path)
    end
  end

  defp serve_entire_file(conn, path) do
    conn
    |> put_resp_content_type(mime(path))
    |> send_file(200, path)
    |> halt()
  end

  defp serve_range(conn, path, range) do
    IO.inspect({:range, path, range})

    case parse_range(path, range) do
      {range_start, range_end, range_length, total_size} ->
        conn
        |> put_resp_content_type(mime(path))
        |> put_resp_header("content-range", "bytes #{range_start}-#{range_end}/#{total_size}")
        |> send_file(206, path, range_start, range_length)
        |> halt()

      _ ->
        serve_entire_file(conn, path)
    end
  end

  defp parse_range(path, range) do
    with {:ok, %{size: total_size}} = File.stat(path),
         %{"bytes" => bytes} <- Plug.Conn.Utils.params(range),
         {range_start, range_end} <- start_and_end(bytes, total_size),
         :ok <- check_bounds(range_start, range_end, total_size) do
      {range_start, range_end, range_end - range_start + 1, total_size}
    else
      _ -> nil
    end
  end

  # *** copied from Plug.Static for now ***

  defp start_and_end("-" <> rest, file_size) do
    case Integer.parse(rest) do
      {last, ""} -> {file_size - last, file_size - 1}
      _ -> :error
    end
  end

  defp start_and_end(range, file_size) do
    case Integer.parse(range) do
      {first, "-"} ->
        {first, file_size - 1}

      {first, "-" <> rest} ->
        case Integer.parse(rest) do
          {last, ""} -> {first, last}
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp check_bounds(range_start, range_end, file_size)
       when range_start < 0 or range_end > file_size or range_start > range_end do
    IO.inspect({:check_bounds_error, range_start, range_end, file_size})
    :error
  end

  defp check_bounds(range_start, range_end, file_size) do
    IO.inspect({:check_bounds_ok, range_start, range_end, file_size})
    :ok
  end
end
