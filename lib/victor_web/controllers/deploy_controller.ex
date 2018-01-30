defmodule VictorWeb.DeployController do
  use VictorWeb, :controller

  plug(:basic_auth)

  @config Application.get_env(:victor, :deploy_notification_auth)
  @username Keyword.get(@config, :username)
  @password Keyword.get(@config, :password)
  @encoded_auth Base.encode64("#{@username}:#{@password}")

  def deploy(conn, _params) do
    _ = Task.async(Victor.Hugo, :build, [conn.assigns.website])
    text(conn, "thanks")
  end

  def basic_auth(conn, _) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> @encoded_auth] ->
        conn

      _ ->
        conn
        |> put_status(401)
        |> text("unauthorized")
        |> halt()
    end
  end
end
