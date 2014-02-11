require 'erb'
require 'fileutils'
require 'pathname'

module WebifyRuby
  # Internal: Template which is according to what a CSS Styles
  # will be generated. This might change in future versions,
  # so that you will be able to pass in your own template definitions.
  TEMPLATE = <<-CSS.gsub /^\s*/, ''
  @font-face {
    font-family: '<%= @name %>';
    <% if has_eot %>src: url('<%= @url %>.eot'); <% end %>
    <% if has_eot %>src: url('<%= @url %>.eot?#iefix') format('embedded-opentype')<%if has_ttf or has_woff or has_svg %>,<%end%><%else%>src:<% end %>
        <% if has_svg %>     url('<%= @url %>.svg#<%= @name %>') format('svg')<%if has_ttf or has_woff %>,<%end%><% end %>
        <% if has_woff %>     url('<%= @url %>.woff') format('woff')<%if has_ttf%>,<%end%><% end %>
        <% if has_ttf %>     url('<%= @url %>.ttf') format('truetype')<% end %>;
    font-weight: normal;
    font-style: normal;
  }
  CSS

  # Public: Css class of the module which is to calculate paths, generate code,
  # and write to a file if explicitely called.
  #
  # Examples
  #
  #   WebifyRuby::Css.new('name', 'example.ttf', :svg)
  #   # => #<WebifyRuby::Css:0x007feec39a5df8>
  class Css
    # Public: Returns the String CSS code.
    attr_reader :result
    # Internal: Returns the String name of the file withotut extension.
    attr_reader :filename
    # Internal: Returns the String prefix of the font url to use in CSS stylesheet.
    attr_reader :url
    # Internal: Returns the String directory path where a .css file should be created.
    attr_reader :dir
    # Internal: Returns the String filepath of the .css file that should be created.
    attr_reader :css_file
    # Internal: Returns the Fixnum length of created file's css content.
    attr_reader :output

    # Public: Check if a class instance has requested to add a type of font to
    # the stylesheet or not. Convert class might need only one or two font urls,
    # that is why it is checking for type validity here.
    #
    # Examples
    #
    #   has_svg
    #   # => true
    #
    # Signature
    #
    #   has_<type>
    #
    # type - A font type string.
    %w(eot svg woff ttf).each do |ext|
      define_method('has_' + ext) { @has.include? ext.to_sym }
    end


    # Public: Used to explicitely define options for a class to calculate what
    # to prepend to Css font url.
    # :relative_from should be nil if :link_to is present.
    #
    # Examples
    #
    #   WebifyRuby::Css.new('test','test.ttf',:svg)
    #   # => #<...>... src: url('test.svg#test')
    #   #
    #   WebifyRuby::Css.relative_from = 'lib/webify.rb'
    #   WebifyRuby::Css.new('test','test.ttf',:svg)
    #   # => #<...>... src: url('../../test.svg#test')
    #   #
    #   WebifyRuby::Css.link_to = 'http://domain.com'
    #   WebifyRuby::Css.new('test','test.ttf',:svg)
    #   # => #<...>... src: url('http://domain.com/test.svg#test')
    #
    # Both, :relative_from and :link_to should not be set
    # :relative_from takes a preference if so.
    class << self;attr_accessor :relative_from, :link_to;end

    # Public: Initialize a CSS generation / distribution.
    #
    # name - A String name that will be used to name a font and stylesheet file.
    # file - A String name that will be used to link to the font files.
    # has  - A zero or more Symbol font types that a stylesheet will use.
    #        Valid symbols are: :eot, :svg, :woff, :ttf.
    #
    # Returns the String CSS stylesheet code.
    def initialize(name, file, *has)
      [name, file, has]

      @has = has
      @name = name

      @filename = File.basename(file, '.*')

      # :nocov:
      @url = (self.class.relative_from.nil? ?
          (self.class.link_to ? (self.class.link_to + '/' + File.basename(file)) : file)
      : Pathname.new(file).relative_path_from(Pathname.new(self.class.relative_from))).to_s[/.*(?=\..+$)/]
      # :nocov:
      
      make_css
    end

    # Internal: (Re-)Create a CSS file and write code there.
    #
    # dir - The String directory path to write CSS file to.
    #
    # Returns the Fixnum length of characters written.
    def write(dir)
      @dir = FileUtils.mkdir_p dir
      @css_file = File.join(@dir, @filename + '.css')

      File.delete(@css_file) if File.exist?(@css_file)
      @output = File.open(@css_file, 'w') { |file| file.write(@result) }
    end

    private

    # Public: Use template to fill placeholders with relevant values.
    #
    # Returns the String containing a CSS stylesheet code.
    def make_css
      template = ERB.new TEMPLATE
      result = template.result binding
      (0..3).each { result.gsub!(/\n;\n/m, ";\n") }
      @result = result.gsub /^$\n/, ''
    end
  end
end