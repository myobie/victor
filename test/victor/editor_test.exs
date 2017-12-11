defmodule Victor.EditorTest do
  use ExUnit.Case, async: true

  alias Victor.Editor
  alias Victor.Editor.{Content, Section}

  test "content in fake hugo site should be parsable" do
    assert {:ok, _} = Editor.content()
  end

  test "sections and subsections parse correctly" do
    {:ok, sections} = Editor.content()

    assert [sec1, sec2, sec3] = sections

    assert length(sec1.subsections) == 0
    assert length(sec2.subsections) == 2
    assert length(sec3.subsections) == 1
  end

  test "should parse the introduction correctly" do
    {:ok, sections} = Editor.content()
    intro = Section.find(sections, "01-introduction")

    assert not is_nil intro
    assert intro.index.body =~ ~r{^Lorem}
    assert Section.title(intro) == "Introduction"
    assert not is_nil Content.get(intro.index, "figure")
    assert is_nil Content.get(intro.index, "categories")
  end

  test "invalid yaml is fine" do
    {:ok, sections} = Editor.content()
    first_part_of_second_section =
      sections
      |> Section.find("02-second")
      |> Section.page("01-first-part.md")

    assert first_part_of_second_section.top_matter == %{}
    assert first_part_of_second_section.body =~ ~r{^---\n}
  end
end
