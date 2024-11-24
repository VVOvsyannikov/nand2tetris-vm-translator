# frozen_string_literal: true

require_relative 'lib/code_writer'
require_relative 'lib/parser'

class Main
  class << self
    def run
      file_name = ARGV[0]
      validate_file_name(file_name)
      process_file(file_name)
    end

    private

    def validate_file_name(file_name)
      return if file_name

      puts 'Error: Please provide a file name.'
      exit(1)
    end

    def process_file(file_name)
      input_path = "files/#{file_name}"
      output_path = "files/#{file_name.gsub('.vm', '.asm')}"

      File.open(input_path, 'r') do |file|
        File.open(output_path, 'w') do |output_file|
          code_writer = CodeWriter.new(output_file)
          Parser.new(file, code_writer).run
        end
      end
    end
  end
end

Main.run
