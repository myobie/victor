defmodule Victor.Editor.Markdown do
  require Logger

  @derive {Poison.Encoder, except: [:path]}
  defstruct path: nil, data: nil, body: nil, frontmatter: %{}

  @type fields :: %{optional(String.t()) => String.t()}
  @type t :: %__MODULE__{
    path: Path.t(),
    data: String.t(),
    body: String.t(),
    frontmatter: fields
  }

  @spec parse(Path.t()) :: {:ok, t} | {:error, term}
  @spec parse(Path.t(), String.t()) :: {:ok, t}

  def parse(path) do
    case File.read(path) do
      {:ok, data} ->
        parse(path, data)
      {:error, error} ->
        _ = Logger.error("Error reading file at #{path} #{inspect(error)}")
        {:error, error}
    end
  end

  def parse(path, data) do
    {body, top} = extract_front_matter(data)

    {:ok, %__MODULE__{
      path: path,
      data: data,
      body: body,
      frontmatter: top
    }}
  end

  @top_regex ~r{^---\n(.+)\n---}s

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
      body = String.slice(original, range) |> String.trim()
      {body, tm}
    catch
      {:yamerl_exception, _} ->
        {original, %{}}
    end
  end
end
