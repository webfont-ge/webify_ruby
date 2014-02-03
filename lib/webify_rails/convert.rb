require 'open3'

module WebifyRails
  class Convert
    def initialize(file)
      raise Errno::ENOENT, "The font file '#{file}' does not exist" unless File.exists?(file)
      @file = file

      command = "#{WebifyRails.webify_binary} #{Shellwords.escape(@file)}"
      output = Open3.popen3(command) { |stdin, stdout, stderr| stdout.read }

      validity = is_valid? output
    end

    def is_valid? (output)
      return false if not output.include? 'Generating' or output.include? 'Failed'
      true
    end
  end
end