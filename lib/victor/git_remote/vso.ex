defmodule Victor.GitRemote.VSO do
  @behaviour Victor.GitRemote.Adapter

  def commit(files, rev) do
    _request = build_request(files, rev)
    # fake commit response for now
    {:ok, "abc"}
  end

  defp build_request(files, rev) do
    %{
      refUpdates: [
        %{
          name: "refs/head/master",
          oldObjectId: rev
        }
      ],
      commits: [
        %{
          comment: "Updated the content",
          changes: build_changes(files)
        }
      ]
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
