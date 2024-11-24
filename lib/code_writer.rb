# frozen_string_literal: true

require_relative 'command_generator'

class CodeWriter
  METHODS_MAPPING = {
    'C_ARITHMETIC' => :write_arithmetic,
    'C_PUSH' => :write_push_pop,
    'C_POP' => :write_push_pop
  }.freeze

  def initialize(output_file)
    @output_file = output_file
    @command_generator = CommandGenerator.new
  end

  def run(command)
    method_name = METHODS_MAPPING[command.type]
    raise "Unsupported command type: #{command.type}" unless method_name

    asm_commands = send(method_name, command)
    write_commands_to_file(command.vm_command, asm_commands)
  end

  private

  def write_arithmetic(command)
    @command_generator.generate_arithmetic(command.command)
  end

  def write_push_pop(command)
    @command_generator.generate_push_pop(command)
  end

  def write_commands_to_file(vm_command, asm_commands)
    comment = "// #{vm_command}\n"
    @output_file.puts("#{comment}#{asm_commands}")
  end
end
