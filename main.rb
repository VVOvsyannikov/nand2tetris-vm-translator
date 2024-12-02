# frozen_string_literal: true

require_relative 'lib/code_writer'
require_relative 'lib/parser'
require_relative 'lib/command'
require_relative 'lib/command_generator'

class Main
  class Source
    attr_reader :vm_files, :asm_filename

    def initialize(vm_files, asm_filename)
      @vm_files = vm_files
      @asm_filename = asm_filename
    end
  end

  class << self
    def run
      path = ARGV[0]
      validate_path(path)

      File.directory?("files/#{path}") ? process_directory("files/#{path}") : process_file("files/#{path}")
    end

    private

    def validate_path(path)
      return if path

      puts 'Error: Please provide a path.'
      exit(1)
    end

    def process_directory(path)
      vm_files = select_vm_files(path)
      asm_file_name = "#{path}/#{path.split('/').last}.asm"

      translate_source_code(Source.new(vm_files, asm_file_name))
    end

    def translate_source_code(source)
      output_file = File.open(source.asm_filename, 'w')
      code_writer = CodeWriter.new(output_file)
      source.vm_files.each { |file| Parser.new(File.open(file), code_writer).run }
    end

    def process_file(path)
      vm_files = [path]
      asm_file_name = path.gsub('.vm', '.asm')

      translate_source_code(Source.new(vm_files, asm_file_name))
    end

    def select_vm_files(path)
      Dir.entries(path).select { |file| file.end_with?('.vm') }.map { |file| "#{path}/#{file}" }
    end
  end
end

Main.run
