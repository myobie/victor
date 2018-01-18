defmodule Victor.EditorTest do
  use ExUnit.Case, async: true

  alias Victor.Editor
  alias Victor.Editor.{Page, Section}

  test "content in fake hugo site should be parsable" do
    assert {:ok, _} = Editor.content()
  end

  test "sections and sections parse correctly" do
    {:ok, sections} = Editor.content()

    assert [sec1, sec2, sec3] = sections

    assert length(sec1.sections) == 1
    assert length(sec2.sections) == 2
    assert length(sec3.sections) == 0
  end

  test "should parse the introduction correctly" do
    {:ok, sections} = Editor.content()
    intro = Section.find(sections, "01-introduction")
    index = Section.index(intro)

    assert not is_nil(intro)
    assert index.body =~ ~r{^Lorem}
    assert Page.title(index) == "Introduction"
    assert not is_nil(Page.get(index, "figure"))
    assert is_nil(Page.get(index, "categories"))
  end

  test "invalid yaml is fine" do
    {:ok, sections} = Editor.content()

    first_part_of_second_section =
      sections
      |> Section.find("02-second")
      |> Section.page("01-first-part.md")

    assert first_part_of_second_section.front_matter == %{}
    assert first_part_of_second_section.body =~ ~r{^---\n}
  end
end
