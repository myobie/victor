defmodule VictorWeb.EditorController do
  use VictorWeb, :controller

  alias Victor.Editor

  def show(conn, _params) do
    with {:ok, sections} <- Editor.content() do
      conn
      |> assign(:sections, sections)
      |> render()
    end
  end

  def update(conn, %{"edits" => edits}) do
    with {:ok, _commit_sha} <- Victor.GitRemote.commit(edits) do
      json conn, %{woo: "hoo"}
    end
  end
end
