require 'redcarpet'
require 'mustache'

class AboutPage < Mustache
  self.template_extension = 'html'
  self.template_path = File.dirname(__FILE__)

  def version
    '0.0.1'
  end

  def dark_brown
    '#453823'
  end

  def light_brown
    '#BAA378'
  end

  def brown
    '#BAA378'
    '#A99267'
    '#877045'
    '#595237'
  end

  def blue
    '#205386'
  end

  def light_blue
    '#003366'
    '#4073A6'
  end

  def white
    '#ffe'
  end

  def content_width
    '640px'
  end

  def content
    markdown.render File.read(about_markdown)
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def about_markdown
    File.join(
      File.dirname(__FILE__),
      '..',
      '..',
      'ABOUT.md'
    )
  end
end
