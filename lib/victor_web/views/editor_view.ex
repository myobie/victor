defmodule VictorWeb.EditorView do
  use VictorWeb, :view

  alias Victor.Editor

  def title(%Editor.Section{} = section),
    do: Editor.Section.title(section)

  def title(%Editor.Content{} = content),
    do: Editor.Content.title(content)
end
