# frozen_string_literal: true

module SilenceOutputHelper
  def silence_output
    @original_stderr = $stderr
    @original_stdout = $stdout

    $stderr = File.new(File.join('tmp', 'stderr.txt'), 'w')
    $stdout = File.new(File.join('tmp', 'stdout.txt'), 'w')
  end

  def restore_output
    $stderr = @original_stderr
    $stdout = @original_stdout
    @original_stderr = nil
    @original_stdout = nil
  end
end
