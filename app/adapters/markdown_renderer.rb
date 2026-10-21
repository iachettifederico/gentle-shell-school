require "commonmarker"

# Renders GitHub-flavored Markdown to HTML. Raw HTML in the source is escaped,
# so authored content cannot inject markup or scripts.
class MarkdownRenderer
  OPTIONS = { render: { unsafe: false, escape: true } }.freeze
  PLUGINS = { syntax_highlighter: nil }.freeze

  def render(markdown)
    Commonmarker.to_html(markdown, options: OPTIONS, plugins: PLUGINS)
  end
end
