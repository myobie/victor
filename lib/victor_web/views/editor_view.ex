defmodule VictorWeb.EditorView do
  use VictorWeb, :view

  alias Victor.Editor

  def title(page), do: Editor.Page.title(page)

  def render("show.json", content) do
    content
  end

  def json_for_javascript(data) do
    raw(
      Poison.encode!(
        render("show.json", data),
        pretty: true,
        strict_keys: true
      )
    )
  end
end
