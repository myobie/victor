defmodule Victor.VSO do
  @behaviour Victor.GitRemote

  def commit(files) do
    with {:ok, rev} <- Victor.Hugo.current_rev() do
      _request = build_request(files, rev)
      {:ok, "abc"} # fake commit response for now
    end
  end

  defp build_request(files, rev) do
    %{
      refUpdates: [%{
        name: "refs/head/master",
        oldObjectId: rev
      }],
      commits: [%{
        comment: "Updated the content",
        changes: Enum.map(Map.to_list(files), fn {path, file} ->
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
      }]
    }
  end
end
