defmodule VictorWeb.EditorController do
  require Logger
  use VictorWeb, :controller

  alias Victor.Editor

  def show(conn, _params) do
    with {:ok, content} <- Editor.content(conn.assigns.website) do
      conn
      |> assign(:content, content)
      |> render()
    else
      other ->
        _ = Logger.error("Error loading website content #{inspect(other)}")

        conn
        |> put_status(500)
        |> json(%{error: "There was a problem loading the website's contents for editing"})
    end
  end

  def update(conn, %{"edits" => edits}) do
    with {:ok, rev} <- Victor.Hugo.current_rev(conn.assigns.website),
         adapter <- Victor.GitRemote.adapter(conn.assigns.website.git_remote.adapter),
         {:ok, _commit_sha} <- adapter.commit(edits, rev) do
      json(conn, %{woo: "hoo"})
    end
  end
end
