defmodule VictorWeb.RequireAuthenticatedUserPlug do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(default), do: default

  def call(%{assigns: %{website: %{authentication: nil}}} = conn, _), do: conn

  def call(%{assigns: %{website: website}} = conn, _default) do
    with {:ok, id_token} <- fetch_session_id_token(conn),
         true <- Victor.Auth.allowed_to_visit?(website, id_token) do
      conn
    else
      _ ->
        conn
        |> redirect(to: "/app/signin")
        |> halt()
    end
  end

  def call(conn, _), do: conn

  @spec fetch_session_id_token(Plug.Conn.t()) :: {:ok, binary} | {:error, :missing_id_token}
  defp fetch_session_id_token(conn) do
    case get_session(conn, "id_token") do
      nil -> {:error, :missing_id_token}
      token -> {:ok, token}
    end
  end
end
