defmodule VictorWeb.EditorController do
  use VictorWeb, :controller

  def show(conn, _params) do
    text conn, "This is the editor"
  end

  def update(conn, _params) do
    text conn, "You tried to update the content"
  end
end
