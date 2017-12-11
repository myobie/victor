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

  def update(conn, _params) do
    text conn, "You tried to update the content"
  end
end
