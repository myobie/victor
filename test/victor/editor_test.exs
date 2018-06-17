defmodule Victor.EditorTest do
  use Victor.UnitCase, async: true

  alias Victor.Editor
  alias Victor.Editor.{Markdown, Section}

  setup do
    website = Victor.Websites.get("www.example.com")
    {:ok, ~M{website}}
  end

  test "content in fake hugo site should be parsable", ~M{website} do
    assert {:ok, _} = Editor.content(website)
  end

  test "sections and sections parse correctly", ~M{website} do
    {:ok, content} = Editor.content(website)

    refute is_nil(content.markdown)
    assert length(content.pages) == 1
    assert length(content.resources) == 2
    assert length(content.children) == 1

    assert [sec1, sec2, sec3] = content.sections

    refute is_nil(sec1.markdown)
    assert length(sec1.sections) == 1
    assert length(sec1.pages) == 2

    assert is_nil(sec2.markdown)
    assert length(sec2.sections) == 2
    assert length(sec2.pages) == 1

    refute is_nil(sec3.markdown)
    assert length(sec3.sections) == 0

    assert [page1, page2] = sec3.pages
    assert page1.id =~ ~r{.md}
    refute page2.id =~ ~r{.md}
  end

  test "should parse the introduction correctly", ~M{website} do
    {:ok, content} = Editor.content(website)
    intro = Section.find(content.sections, "01-introduction")

    assert not is_nil(intro)
    assert intro.markdown.body =~ ~r{^Lorem}
    assert Section.title(intro) == "Introduction"
    assert not is_nil(Section.get(intro, "figure"))
    assert is_nil(Section.get(intro, "categories"))
  end

  test "invalid yaml is fine" do
    {:ok, _} =
      Markdown.parse("test.md", """
      ---
      title: This yaml is correct
      ---

      Body
      """)

    {:ok, _} =
      Markdown.parse("test.md", """
      ---
      title: This yaml is not
      this is not a valid key
      ---

      Body
      """)

    {:ok, _} =
      Markdown.parse("test.md", """
      ---
      title: This yaml is not
      yaml never ends

      Body
      """)
  end
end
