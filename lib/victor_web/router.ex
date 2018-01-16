defmodule VictorWeb.Router do
  use VictorWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :notifications do
    plug(:accepts, ["html", "json"])
    plug(:put_secure_browser_headers)
  end

  pipeline :feature do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  pipeline :hugo do
    plug(:append_index)

    # server all static files that are compiled by hugo at the root
    plug(
      Plug.Static,
      at: "/",
      from: Victor.Hugo.public_path(),
      gzip: false
    )
  end

  pipeline :authenticated do
    plug(:authenticate)
  end

  def authenticate(conn, _) do
    if authenticated?(conn) do
      conn
    else
      conn
      |> redirect(to: "/app/signin")
      |> halt()
    end
  end

  @jwt_type ["PS256"]

  defp authenticated?(conn) do
    with id_token when not is_nil(id_token) <- get_session(conn, "id_token") do
      case JOSE.JWT.verify_strict(Victor.Auth.public_key(), @jwt_type, id_token) do
        {true, %{fields: fields}, _jws} ->
          Victor.Auth.valid?(fields)

        _ ->
          false
      end
    else
      _ -> false
    end
  end

  def append_index(conn, _) do
    case conn do
      %{method: "GET", request_path: path} ->
        cond do
          hugo_dir?(path) -> append_index_dot_html(conn)
          true -> conn
        end

      _ ->
        conn
    end
  end

  defp append_index_dot_html(%Plug.Conn{} = conn) do
    %{
      conn
      | path_info: append_index_dot_html({:path_info, conn.path_info}),
        script_name: append_index_dot_html({:script_name, conn.script_name}),
        request_path: append_index_dot_html({:request_path, conn.request_path})
    }
  end

  defp append_index_dot_html({:path_info, path_info}), do: path_info ++ ["index.html"]

  defp append_index_dot_html({:script_name, _script_name}), do: ["index.html"]

  defp append_index_dot_html({:request_path, request_path}),
    do: Path.join(request_path, "index.html")

  defp hugo_dir?(path), do: Victor.Hugo.public_path() |> Path.join(path) |> File.dir?()

  scope "/app", VictorWeb do
    pipe_through(:browser)

    get("/signin", AuthController, :signin)
    get("/signout", AuthController, :signout)
    get("/auth/callback", AuthController, :callback)
  end

  scope "/app", VictorWeb do
    pipe_through(:notifications)

    post("/deploy-notification", DeployController, :deploy)
  end

  scope "/app/editor", VictorWeb do
    pipe_through(:feature)
    pipe_through(:authenticated)

    get("/*anything", EditorController, :show)
    post("/", EditorController, :update)
  end

  scope "/", VictorWeb do
    pipe_through(:browser)

    if match?({:ok, true}, Application.fetch_env(:victor, :requires_authentication)) do
      pipe_through(:authenticated)
    end

    pipe_through(:hugo)

    match(:*, "/*anything", PageController, :not_found)
  end
end
