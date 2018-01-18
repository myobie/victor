defmodule Victor.Editor.Page do
  @derive {Poison.Encoder, except: [:path, :error]}
  defstruct id: nil, path: nil, body: "", front_matter: %{}, error: nil

  require Logger
  import Victor.Editor.Helpers

  @type fields :: %{optional(String.t()) => String.t()}
  @type t :: %__MODULE__{
          id: String.t(),
          path: Path.t(),
          body: String.t(),
          front_matter: fields,
          error: term
        }

  @spec get(t, String.t()) :: String.t() | nil
  def get(%__MODULE__{front_matter: tm}, field), do: Map.get(tm, field)

  @spec fetch(t, String.t()) :: {:ok, String.t()} | :error
  def fetch(%__MODULE__{front_matter: tm}, field), do: Map.fetch(tm, field)

  @spec title(t) :: String.t() | nil
  def title(%__MODULE__{} = content), do: get(content, "title")

  @spec from(Path.t()) :: t
  def from(path) do
    case File.read(path) do
      {:ok, data} ->
        {body, top} = extract_front_matter(data)

        %__MODULE__{
          id: get_id(path),
          path: path,
          body: body,
          front_matter: top
        }

      error ->
        _ = Logger.debug("Error reading file at #{path} #{inspect(error)}")
        %__MODULE__{error: error}
    end
  end

  @top_regex ~r{^---\n(.+)---\n\n}s

  @spec extract_front_matter(String.t()) :: {String.t(), fields}
  defp extract_front_matter(text) do
    case Regex.run(@top_regex, text, return: :index) do
      [{0, body_begin}, {yaml_begin, yaml_length}] ->
        text
        |> String.slice(yaml_begin, yaml_length)
        |> extract_yaml(text, body_begin..-1)

      _ ->
        {text, %{}}
    end
  end

  @spec extract_yaml(String.t(), String.t(), Range.t()) :: {String.t(), fields}
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
