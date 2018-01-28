defmodule VictorWeb.EditorController do
  use VictorWeb, :controller

  alias Victor.Editor

  def show(conn, _params) do
    with {:ok, sections} <- Editor.content(conn.assigns.website) do
      conn
      |> assign(:sections, sections)
      |> render()
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
