require 'FileUtils'
require 'open3'

module WebifyRails
  class Convert
    attr_reader :file, :original_file, :command, :output, :generated, :original_dir, :result_dir, :desired_dir

    def initialize(file, dir: nil)
      [file, dir]

      @desired_dir = dir

      raise Errno::ENOENT, "The font file '#{file}' does not exist" unless File.exists?(file)
      @original_file = file

      @original_dir = File.dirname(@original_file)
      raise Errno::ENOENT, "Can't find directory '#{@original_dir}'" unless File.directory? @original_dir

      @result_dir = Dir.mktmpdir(nil, destination_dir)

      FileUtils.cp(@original_file, @result_dir)

      @file = File.join(@result_dir, File.basename(@original_file))

      process

      #if not created_any?
      #  WebifyRails.logger.warn "Host did not create any files\n@command\n#{@command}\n@output\n#{@output}\n"
      #  raise Error, "No were created:\n#{@output}"
      #end
    end

    protected

    def is_valid? (output)
      false if not output.include? 'Generating' or output.include? 'Failed'
      true
    end
    #
    #def created_any?
    #  true
    #end

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

    private

    def process
      @command = "#{WebifyRails.webify_binary} #{Shellwords.escape(@file)}"
      @output = Open3.popen3(@command) { |stdin, stdout, stderr| stdout.read }

      Shellwords.escape(@output).split("'\n'").select{|s| s.match('font')}.join().split('Generating\\ ')[1..-1]

      if not is_valid? @output
        WebifyRails.logger.fatal "Invalid input received\n@command\n#{@command}\n@output\n#{@output}\n"
        raise Error, "Binary responded with failure:\n#{@output}"
      end

      @generated = Shellwords.escape(@output).split("'\n'").select{|s| s.match('Generating')}.join().split('Generating\\ ')[1..-1]

      if @generated.to_a.empty?
        WebifyRails.logger.fatal "No file output received\n@command\n#{@command}\n@output\n#{@output}\n"
        raise Error, "No file output received:\n#{@output}"
      end
    end
  end
end