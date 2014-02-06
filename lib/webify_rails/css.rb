require 'erb'
require 'fileutils'
require 'pathname'

module WebifyRails
  TEMPLATE = <<-CSS.gsub /^\s*/, ''
  @font-face {
    font-family: '<%= @name %>';
    <% if has_eot %>src: url('<%= @file %>.eot'); <% end %>
    <% if has_eot %>src: url('<%= @file %>.eot?#iefix') format('embedded-opentype')<%if has_ttf or has_woff or has_svg %>,<%end%><%else%>src:<% end %>
        <% if has_svg %>     url('<%= @file %>.svg#<%= @name %>') format('svg')<%if has_ttf or has_woff %>,<%end%><% end %>
        <% if has_woff %>     url('<%= @file %>.woff') format('woff')<%if has_ttf%>,<%end%><% end %>
        <% if has_ttf %>     url('<%= @file %>.ttf') format('truetype')<% end %>;
    font-weight: normal;
    font-style: normal;
  }
  CSS

  class Css
    attr_reader :result, :filename, :file, :dir, :css_file, :output

    %w(eot svg woff ttf).each do |ext|
      define_method('has_' + ext) { @has.include? ext.to_sym }
    end

    class << self;attr_accessor :path_before;end

    def initialize(name, file, link_to, *has)
      [name, file, has]

      @has = has
      @name = name

      @filename = File.basename(file, '.*')

      @file = (self.class.path_before.nil? ?
          (link_to ? (link_to + '/' + File.basename(file)) : file)
      : Pathname.new(file).relative_path_from(Pathname.new(self.class.path_before))).to_s[/.*(?=\..+$)/]

      make_css
    end

    def write(dir)
      @dir = FileUtils.mkdir_p dir
      @css_file = File.join(@dir, @filename + '.css')

      File.delete(@css_file) if File.exist?(@css_file)
      @output = File.open(@css_file, 'w') { |file| file.write(@result) }
    end

    private

    def make_css
      template = ERB.new TEMPLATE
      result = template.result binding
      (0..3).each { result.gsub!(/\n;\n/m, ";\n") }
      @result = result.gsub /^$\n/, ''
    end
  end
end