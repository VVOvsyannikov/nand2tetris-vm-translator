# frozen_string_literal: true

require_relative 'command_generator'

class CodeWriter
  METHODS_MAPPING = {
    'C_ARITHMETIC' => :write_arithmetic,
    'C_PUSH' => :write_push_pop,
    'C_POP' => :write_push_pop,
    'C_LABEL' => :write_label,
    'C_GOTO' => :write_goto,
    'C_IF' => :write_if,
    'C_FUNCTION' => :write_function,
    'C_RETURN' => :write_return,
    'C_CALL' => :write_call
  }.freeze

  def initialize(output_file)
    @output_file = output_file
    @command_generator = CommandGenerator.new(set_file_name(output_file))
    write_init
  end

  def run(command)
    method_name = METHODS_MAPPING[command.type]
    raise "Unsupported command type: #{command.type}" unless method_name

    asm_commands = send(method_name, command)
    write_commands_to_file(command.vm_command, asm_commands)
  end

  private

  def write_init
    asm_commands = @command_generator.generate_init

    write_commands_to_file('init', asm_commands)
  end

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

  def set_file_name(output_file)
    output_file.path.split('/').last.split('.').first
  end

  def write_label(command)
    @command_generator.generate_label(command)
  end

  def write_goto(command)
    @command_generator.generate_goto(command)
  end

  def write_if(command)
    @command_generator.generate_if(command)
  end

  def write_function(command)
    @command_generator.generate_function(command)
  end

  def write_return(command)
    @command_generator.generate_return(command)
  end

  def write_call(command)
    @command_generator.generate_call(command)
  end
end
