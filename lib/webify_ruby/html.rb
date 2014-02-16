require 'erb'
require 'fileutils'
require 'pathname'

module WebifyRuby
  # Internal: Template which is according to what a CSS Styles
  # will be generated. This might change in future versions,
  # so that you will be able to pass in your own template definitions.
  HTML_DOC = <<-HTML.gsub /^\s*/, ''
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="utf-8">
    <title><%=@font_name%> - WebifyRuby</title>
    <link rel="stylesheet" type="text/css" href="<%=@css_file%>">
    <style>
    ::-moz-selection {
      background: #b3d4fc;
      text-shadow: none;
    }

    ::selection {
      background: #b3d4fc;
      text-shadow: none;
    }

    html {
      padding: 30px 10px;
      font-size: 20px;
      line-height: 1.4;
      color: #737373;
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
   
      background-color: #fff; 
      background-image: 
      linear-gradient(90deg, transparent 79px, #737373 79px, #737373 81px, transparent 81px),
      linear-gradient(#eee .1em, transparent .1em);
      background-size: 100% 1.2em;
    
      font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
  
    a:link,a:visited,a:hover,a:active {
      color:inherit; 
      text-decoration:none;
    }

    body {
      max-width: 750px;
      _width: 750px;
      padding: 30px 20px 50px;
      margin: 0 auto;
    }

    h1 {
      margin: 5px 10px;
      font-size: 40px;
      text-align: center;
    }

    h1 span {
      color: #bbb;
    }

    h3 {
      margin: 1.5em 0 0.5em;
    }

    p {
      margin: 0.5em 0;
    }

    ul {
      margin: 1em 0;
      list-style:none;
      font-family:<%=@font_name%>;
      border:1px solid #ccc;
      padding:15px;
      background: #fff;
    }
  
    ul li {
      display:inline-block;
      height:50px;
      width:50px;;
      text-align:center;
      line-height:50px;
      margin:10px;
      background: #fff;
    }

    .container {
      max-width: 700px;
      _width: 700px;
      margin: 0 auto;
    }

    input::-moz-focus-inner {
      padding: 0;
      border: 0;
    }
    </style>
  </head>
  <body>
    <a href="https://github.com/dachi-gh/webify_ruby"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://github-camo.global.ssl.fastly.net/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png"></a>
    
    <div class="container">
      <h1><a href="https://github.com/dachi-gh/webify_ruby">WebifyRuby <span>Gem</span></a></h1>
      <p>
        <strong><%=Time.now%></strong>
      </p>
      <p>
        <strong><%=@font_name%></strong>
      </p>
      <p>The result looks like this:</p>
      <ul>
        <%("a".."z").each do |l|%>
        <li><%=l.upcase%> <%=l%></li>
        <%end%>
      </ul>
      <p>
        <small>Github page: <a href="https://github.com/dachi-gh/webify_ruby">https://github.com/dachi-gh/webify_ruby</a></small>
      </p>
    </div>
  </body>
  </html>
  HTML

  # Public: Css class of the module which is to calculate paths, generate code,
  # and write to a file if explicitely called.
  #
  # Examples
  #
  #   WebifyRuby::Css.new('name', 'example.ttf', :svg)
  #   # => #<WebifyRuby::Css:0x007feec39a5df8>
  class Html
    # Public: Returns the String CSS code.
    attr_reader :css_file
    # Internal: Returns the String name of the file withotut extension.
    attr_reader :html_dir
    # Internal: Returns the String prefix of the font url to use in CSS stylesheet.
    attr_reader :font_name
    # Internal: Returns the String directory path where a .css file should be created.
    attr_reader :html_file
    attr_reader :output
    attr_reader :result

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

    # Public: Initialize a CSS generation / distribution.
    #
    # name - A String name that will be used to name a font and stylesheet file.
    # file - A String name that will be used to link to the font files.
    # has  - A zero or more Symbol font types that a stylesheet will use.
    #        Valid symbols are: :eot, :svg, :woff, :ttf.
    #
    # Returns the String CSS stylesheet code.
    def initialize(css_file, html_dir)
      @css_file = css_file
      @html_dir = html_dir
      @font_name = File.basename(@css_file, ".*")

      make_html
      write
    end

    # Internal: (Re-)Create a CSS file and write code there.
    #
    # dir - The String directory path to write CSS file to.
    #
    # Returns the css file just written.
    def write
      @dir = FileUtils.mkdir_p @html_dir unless File.directory? @html_dir
      @html_file = File.join(@html_dir, @font_name + '.html')

      File.delete(@html_file) if File.exist?(@html_file)
      @output = File.open(@html_file, 'w') { |file| file.write(@result) }
      @html_file
    end

    private

    # Public: Use template to fill placeholders with relevant values.
    #
    # Returns the String containing a CSS stylesheet code.
    def make_html
      template = ERB.new HTML_DOC
      @result = template.result binding
    end
  end
end