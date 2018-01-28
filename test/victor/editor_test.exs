defmodule Victor.EditorTest do
  import ShorterMaps
  use ExUnit.Case, async: true

  alias Victor.Editor
  alias Victor.Editor.{Page, Section}

  setup do
    website = Victor.Websites.get("www.example.com")
    {:ok, ~M{website}}
  end

  test "content in fake hugo site should be parsable", ~M{website} do
    assert {:ok, _} = Editor.content(website)
  end

  test "sections and sections parse correctly", ~M{website} do
    {:ok, sections} = Editor.content(website)

    assert [sec1, sec2, sec3] = sections

    assert length(sec1.sections) == 1
    assert length(sec2.sections) == 2
    assert length(sec3.sections) == 0
  end

  test "should parse the introduction correctly", ~M{website} do
    {:ok, sections} = Editor.content(website)
    intro = Section.find(sections, "01-introduction")
    index = Section.index(intro)

    assert not is_nil(intro)
    assert index.body =~ ~r{^Lorem}
    assert Page.title(index) == "Introduction"
    assert not is_nil(Page.get(index, "figure"))
    assert is_nil(Page.get(index, "categories"))
  end

  test "invalid yaml is fine", ~M{website} do
    {:ok, sections} = Editor.content(website)

    first_part_of_second_section =
      sections
      |> Section.find("02-second")
      |> Section.page("01-first-part.md")

    assert first_part_of_second_section.front_matter == %{}
    assert first_part_of_second_section.body =~ ~r{^---\n}
  end
end
