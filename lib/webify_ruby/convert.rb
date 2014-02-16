require 'fileutils'
require 'open3'
require 'tmpdir'
require 'shellwords'

module WebifyRuby
  # Public: Core class of the model that converts and distributes if necessary.
  #
  # Examples
  #
  #   WebifyRuby::Convert.new('../public/fonts/example.ttf', :css => true)
  #   # => #<WebifyRuby::Convert:0x007f92ca0c12c8>
  class Convert
    # Public: Returns the String new file path of the inputted file.
    attr_reader :file
    # Internal: Returns the String inputted file.
    attr_reader :original_file
    # Public: Returns the String command that was executed.
    attr_reader :command
    # Public: Returns the String STDOUT from the binary.
    attr_reader :output
    # Public: Returns the Array of created files.
    attr_reader :generated
    # Internal: Returns the String directory path of file inputted.
    attr_reader :original_dir
    # Public: Returns the String directory path of the destination.
    attr_reader :result_dir
    # Internal: Returns the String directory path of the custom directory.
    attr_reader :desired_dir
    # Internal: Returns the String or Mixed value of desired CSS behavior.
    attr_reader :css
    # Internal: Returns the String path of CSS url prefix.
    attr_reader :link_to
    # Public: Returns the String CSS stylesheet code if possible.
    attr_reader :styles
    # Public: Returns the filepath of CSS file created if applicable.
    attr_reader :css_file

    # Public: Initialize a Convertion of font-file.
    #
    # file     - A String containing relative or full path of file to convert.
    # :dir     - A String indicating to the desired to save converted files (optional).
    # :css     - A String or Boolean value indicating a desired CSS behavior.
    #            If present, it can be either directory path in String or Boolean.
    #            If value is set to true, then a stylesheet file won't be created,
    #            but code will become accessible as :styles attribute (optional).
    # :link_to - A String notation indicating how to prefix a font url in CSS (optional).
    #
    # Returns nothing.
    # Raises Errno::ENOENT if the inputted file cannot be found.
    # Raises Error if the inputted font file is not withing valid extensions.
    # Raises Error::ENOENT if the directory of inputted file is not accessible.
    def initialize(file, dir: nil, css: nil, link_to: nil)
      [file, dir, css, link_to]

      @desired_dir = dir
      @css = css
      @link_to = link_to

      raise Errno::ENOENT, "The font file '#{file}' does not exist" unless File.exists?(file)
      @original_file = file

      raise Error, "The font file '#{file}' is not valid" unless WebifyRuby::EXT.include? File.extname(@original_file)

      @original_dir = File.dirname(@original_file)
      raise Errno::ENOENT, "Can't find directory '#{@original_dir}'" unless File.directory? @original_dir

      @result_dir = Dir.mktmpdir(nil, destination_dir)

      FileUtils.cp(@original_file, @result_dir)

      @file = File.join(@result_dir, File.basename(@original_file))

      process

      
      if affected_files.to_a.length == 0
        # :nocov:
        WebifyRuby.logger.info "Host did not create any files\n@command\n#{@command}\n@output\n#{@output}\n"
        # :nocov:
      end

      generate_css unless @css.nil?
    end

    # Internal: Know files that have been touched by running binary command.
    #
    # Returns the Array of affected files.
    def affected_files
      Dir[@result_dir + '/*.{ttf,eot,woff,svg}'].reject { |f| f[@file] }
    end

    # Internal: Try check if running a command resulted in a positive or negative
    # output about the file you want to convert.
    #
    # Returns the Boolean saying if file was valid to convert or not.
    def is_valid?
      false if not @output.include? 'Generating' or @output.include? 'Failed'
      true
    end

    # Internal: Communicate with Css class and take care of stylesheet
    # creation, code generation and distribution.
    # Method generates Css if attribute is present and writes to a file
    # if attribute possibly is a directory.
    #
    # Returns the CSS filepath, code written or nothing.
    def generate_css
      needs = affected_files.map { |m| File.extname(m)[1..-1].to_sym }

      WebifyRuby::Css.link_to = @link_to
    
      if should_write_css?
        WebifyRuby::Css.relative_from = @link_to ? nil : @css
      end
        
      css = WebifyRuby::Css.new(File.basename(@file, ".*"), @file, *needs)
      @styles = css.result

      @css_file = css.write @css if should_write_css?
    end

    protected

    # Internal: Class should know if you want to write a Css or not
    # It checks by looking at given :css attribute, if it responds to
    # string, then it might be a new or existing directory path,
    # otherwise it assumes writing a file is not required.
    #
    # Returns the Boolean notation about writing a file or not.
    def should_write_css?
      @css.respond_to?(:to_str) and not @css.to_s.empty?
    end

    private

    # Internal: A place where font files need to be outputted may differ,
    # You might want them to be in the same directory as original file,
    # or in a different one that exists, or perhaps needs to be created.
    #
    # Returns the String directory path where files will be created.
    def destination_dir
      if @desired_dir.nil?
        @original_dir
      else
        if not File.directory?(@desired_dir)
          FileUtils.mkdir_p(@desired_dir)
        else
          @desired_dir
        end
      end
    end

    # Internal: A stage where communication is done with a binary and
    # supplied arguments.
    #
    # Returns the Array of files that were generated
    # Raises Error if a binary fails to respond positively to our input.
    # :nocov:
    def process
      @command = "#{WebifyRuby.webify_binary} #{Shellwords.escape(@file)}"
      @output = Open3.popen3(@command) { |stdin, stdout, stderr| stdout.read }

      if not is_valid?
        WebifyRuby.logger.fatal "Invalid input received\n@command\n#{@command}\n@output\n#{@output}\n"
        raise Error, "Binary responded with failure:\n#{@output}"
      end

      @generated = Shellwords.escape(@output).split("'\n'").select{|s| s.match('Generating')}.join().split('Generating\\ ')[1..-1]

      if @generated.to_a.empty?
        WebifyRuby.logger.info "No file output received\n@command\n#{@command}\n@output\n#{@output}\n"
      end
    end
    # :nocov:
  end
end