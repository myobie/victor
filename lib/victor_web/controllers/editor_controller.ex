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
    with {:ok, rev} <- Victor.Hugo.current_rev() do
      json conn, build_vsts_request(edits, rev)
    end
  end

  defp build_vsts_request(edits, current_rev) do
    %{
      refUpdates: [%{
        name: "refs/head/master",
        oldObjectId: current_rev
      }],
      commits: [%{
        comment: "Updated the content",
        changes: Enum.map(Map.to_list(edits), fn {path, content} ->
          %{
            changeType: "edit",
            item: %{
              path: "/content/#{path}"
            },
            newContent: %{
              content: content,
              contentType: "text/markdown"
            }
          }
        end)
      }]
    }
  end
end
