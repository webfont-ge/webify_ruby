require 'fileutils'
require 'open3'

module WebifyRails
  class Convert
    attr_reader :file, :original_file, :command, :output, :generated, :original_dir, :result_dir, :desired_dir, :css, :styles

    def initialize(file, dir: nil, css: nil)
      [file, dir]

      @desired_dir = dir
      @css = css

      raise Errno::ENOENT, "The font file '#{file}' does not exist" unless File.exists?(file)
      @original_file = file

      raise Error, "The font file '#{file}' is not valid" unless WebifyRails::EXT.include? File.extname(@original_file)

      @original_dir = File.dirname(@original_file)
      raise Errno::ENOENT, "Can't find directory '#{@original_dir}'" unless File.directory? @original_dir

      @result_dir = Dir.mktmpdir(nil, destination_dir)

      FileUtils.cp(@original_file, @result_dir)

      @file = File.join(@result_dir, File.basename(@original_file))

      process

      if affected_files.to_a.length == 0
        WebifyRails.logger.info "Host did not create any files\n@command\n#{@command}\n@output\n#{@output}\n"
      end

      unless @css.nil?
        needs = affected_files.map { |m| File.extname(m)[1..-1].to_sym }
        css = WebifyRails::Css.new(File.basename(@original_file, ".*"), File.basename(@original_file, ".*"), *needs)
        @styles = css.result
        css.write @css if @css.respond_to?(:to_str) and not @css.to_s.empty?
      end
    end

    def affected_files
      Dir[@result_dir + '/*.{ttf,eot,woff,svg}'].reject { |f| f[@file] }
    end

    def is_valid?
      false if not @output.include? 'Generating' or @output.include? 'Failed'
      true
    end

    protected

    private

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

    def process
      @command = "#{WebifyRails.webify_binary} #{Shellwords.escape(@file)}"
      @output = Open3.popen3(@command) { |stdin, stdout, stderr| stdout.read }

      if not is_valid?
        WebifyRails.logger.fatal "Invalid input received\n@command\n#{@command}\n@output\n#{@output}\n"
        raise Error, "Binary responded with failure:\n#{@output}"
      end

      @generated = Shellwords.escape(@output).split("'\n'").select{|s| s.match('Generating')}.join().split('Generating\\ ')[1..-1]

      if @generated.to_a.empty?
        WebifyRails.logger.info "No file output received\n@command\n#{@command}\n@output\n#{@output}\n"
      end
    end
  end
end