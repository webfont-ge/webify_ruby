require 'erb'

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
    attr_accessor :result

    %w(eot svg woff ttf).each do |ext|
      define_method('has_' + ext) { true }
    end

    def initialize(name, file)
      @name = name
      @file = file

      make_css
    end

    private

    def get_binding
      binding
    end

    def make_css
      template = ERB.new TEMPLATE

      result = template.result(get_binding)

      (0..3).each { result.gsub!(/\n;\n/m, ";\n") }

      @result = result.gsub /^$\n/, ''
    end
  end

  #p Css.new('test','file').result
end