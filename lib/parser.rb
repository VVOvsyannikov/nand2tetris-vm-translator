# frozen_string_literal: true

class Parser
  COMMAND_TYPES = {
    'add' => 'C_ARITHMETIC', 'sub' => 'C_ARITHMETIC', 'neg' => 'C_ARITHMETIC',
    'eq' => 'C_ARITHMETIC', 'gt' => 'C_ARITHMETIC', 'lt' => 'C_ARITHMETIC',
    'and' => 'C_ARITHMETIC', 'or' => 'C_ARITHMETIC', 'not' => 'C_ARITHMETIC',
    'push' => 'C_PUSH', 'pop' => 'C_POP', 'label' => 'C_LABEL',
    'goto' => 'C_GOTO', 'if-goto' => 'C_IF', 'function' => 'C_FUNCTION',
    'return' => 'C_RETURN', 'call' => 'C_CALL'
  }.freeze

  def initialize(input_file, code_writer)
    @code_writer = code_writer
    @input_file = input_file
    @current_command = nil
  end

  def run
    while more_command?
      next_line = advance
      @current_command = build_current_command(next_line)
      next unless @current_command

      write_command_to_file
      clean_current_command
    end
  end

  private

  def build_current_command(line)
    vm_command = clean(line)
    command, arg1, arg2 = vm_command.split
    return nil if command.nil? || comment?(vm_command)

    type = COMMAND_TYPES[command]
    Command.new(vm_command, command, type, arg1, arg2)
  end

  def write_command_to_file
    @code_writer.run(@current_command)
  end

  def clean_current_command
    @current_command = nil
  end

  def more_command?
    !@input_file.eof?
  end

  def advance
    @input_file.gets
  end

  def command_type
    @current_command.type
  end

  def arg1
    @current_command.arg1
  end

  def arg2
    @current_command.arg2.to_i
  end

  def clean(line)
    line.strip
  end

  def comment?(line)
    line.start_with?('//')
  end
end
