defmodule Victor.Editor.Content do
  @derive {Poison.Encoder, except: [:path, :error]}
  defstruct id: nil, path: nil, body: "", top_matter: %{}, error: nil

  require Logger
  import Victor.Editor.Helpers

  def get(%__MODULE__{top_matter: tm}, field),
    do: Map.get(tm, field)

  def fetch(%__MODULE__{top_matter: tm}, field),
    do: Map.fetch(tm, field)

  def title(%__MODULE__{} = content),
    do: get(content, "title")

  def from(path) do
    case File.read(path) do
      {:ok, data} ->
        {body, top} = extract_top_matter(data)
        %__MODULE__{
          id: get_id(path),
          path: path,
          body: body,
          top_matter: top
        }
      error ->
        Logger.debug "Error reading file at #{path} #{inspect error}"
        %__MODULE__{error: error}
    end
  end

  @top_regex ~r{^---\n(.+)---\n\n}s
  # [_, match] = Regex.run(@top_regex, body)

  defp extract_top_matter(text) do
    case Regex.run(@top_regex, text, return: :index) do
      [{0, body_begin}, {yaml_begin, yaml_length}] ->
        text
        |> String.slice(yaml_begin, yaml_length)
        |> extract_yaml(text, body_begin..-1)
      _ ->
        {text, %{}}
    end
  end

  defp extract_yaml(yaml, original, range) do
    try do
      tm = YamlElixir.read_from_string(yaml)
      body = String.slice(original, range)
      {body, tm}
    catch
      {:yamerl_exception, _} ->
      {original, %{}}
    end
  end
end
