# frozen_string_literal: true

class CommandGenerator
  def initialize
    @current_row = 0
  end

  def generate_arithmetic(command)
    case command
    when 'add' then add
    when 'sub' then sub
    when 'neg' then neg
    when 'eq' then eq
    when 'gt' then gt
    when 'lt' then lt
    when 'and' then and_op
    when 'or' then or_op
    when 'not' then not_op
    else
      raise "Unsupported arithmetic command: #{command}"
    end
  end

  def generate_push_pop(command)
    method_name = "#{command.command}_#{command.arg1}"
    raise "Unsupported push/pop command: #{method_name}" unless respond_to?(method_name, true)

    send(method_name, command.arg2)
  end

  private

  def increment_row(lines)
    @current_row += lines
  end

  # Arithmetic Commands
  def add
    increment_row(10)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @SP
      M=M-1
      A=M
      M=D+M
      @SP
      M=M+1
    ASM
  end

  def sub
    increment_row(10)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @SP
      M=M-1
      A=M
      M=M-D
      @SP
      M=M+1
    ASM
  end

  def neg
    increment_row(6)
    <<~ASM
      @SP
      M=M-1
      A=M
      M=-M
      @SP
      M=M+1
    ASM
  end

  def eq
    generate_comparison('JEQ')
  end

  def gt
    generate_comparison('JGT')
  end

  def lt
    generate_comparison('JLT')
  end

  def and_op
    increment_row(10)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @SP
      M=M-1
      A=M
      M=D&M
      @SP
      M=M+1
    ASM
  end

  def or_op
    increment_row(10)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @SP
      M=M-1
      A=M
      M=D|M
      @SP
      M=M+1
    ASM
  end

  def not_op
    increment_row(6)
    <<~ASM
      @SP
      M=M-1
      A=M
      M=!M
      @SP
      M=M+1
    ASM
  end

  def generate_comparison(jump_command)
    increment_row(20)
    true_label = "TRUE#{@current_row}"
    end_label = "END#{@current_row}"
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @SP
      M=M-1
      A=M
      D=M-D
      @#{true_label}
      D;#{jump_command}
      @SP
      A=M
      M=0
      @#{end_label}
      0;JMP
      (#{true_label})
      @SP
      A=M
      M=-1
      (#{end_label})
      @SP
      M=M+1
    ASM
  end

  # Push/Pop Commands
  def push_constant(value)
    increment_row(7)
    <<~ASM
      @#{value}
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ASM
  end

  def push_local(value)
    generate_push_segment('LCL', value)
  end

  def pop_local(value)
    generate_pop_segment('LCL', value)
  end

  def push_argument(value)
    generate_push_segment('ARG', value)
  end

  def pop_argument(value)
    generate_pop_segment('ARG', value)
  end

  def push_this(value)
    generate_push_segment('THIS', value)
  end

  def pop_this(value)
    generate_pop_segment('THIS', value)
  end

  def push_that(value)
    generate_push_segment('THAT', value)
  end

  def pop_that(value)
    generate_pop_segment('THAT', value)
  end

  def push_temp(value)
    increment_row(7)
    <<~ASM
      @#{5 + value.to_i}
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ASM
  end

  def pop_temp(value)
    increment_row(11)
    <<~ASM
      @#{5 + value.to_i}
      D=A
      @R13
      M=D
      @SP
      M=M-1
      A=M
      D=M
      @R13
      A=M
      M=D
    ASM
  end

  def push_pointer(value)
    increment_row(7)
    segment = value.to_i.zero? ? 'THIS' : 'THAT'
    <<~ASM
      @#{segment}
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ASM
  end

  def pop_pointer(value)
    increment_row(6)
    segment = value.to_i.zero? ? 'THIS' : 'THAT'
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @#{segment}
      M=D
    ASM
  end

  def push_static(value)
    increment_row(7)
    <<~ASM
      @#{filename}.#{value}
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ASM
  end

  def pop_static(value)
    increment_row(6)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M
      @#{filename}.#{value}
      M=D
    ASM
  end

  # Helper for segments
  def generate_push_segment(segment, value)
    increment_row(10)
    <<~ASM
      @#{value}
      D=A
      @#{segment}
      A=D+M
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ASM
  end

  def generate_pop_segment(segment, value)
    increment_row(14)
    <<~ASM
      @#{value}
      D=A
      @#{segment}
      D=D+M
      @R13
      M=D
      @SP
      M=M-1
      A=M
      D=M
      @R13
      A=M
      M=D
    ASM
  end
end
