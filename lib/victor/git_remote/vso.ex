defmodule Victor.GitRemote.VSO do
  alias Victor.GitRemote
  @behaviour GitRemote

  def commit(files, rev) do
    _request = build_request(files, rev)
    {:ok, "abc"} # fake commit response for now
  end

  defp build_request(files, rev) do
    %{
      refUpdates: [%{
        name: "refs/head/master",
        oldObjectId: rev
      }],
      commits: [%{
        comment: "Updated the content",
        changes: build_changes(files)
      }]
    }
  end

  defp build_changes(files) do
    Enum.map(Map.to_list(files), fn {path, file} ->
      %{
        changeType: "edit",
        item: %{
          path: "/content/#{path}"
        },
        newContent: %{
          content: file.content,
          contentType: file.type
        }
      }
    end)
  end
end
