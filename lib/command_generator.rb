# frozen_string_literal: true

class CommandGenerator
  def initialize(filename)
    @filename = filename
    @current_row = 0
    @function_calls_counter = Hash.new(0)
    @current_function = nil
  end

  def generate_init
    increment_row(20)
    <<~ASM
      // set @SP
      @256
      D=A
      @SP
      M=D
      // set @LCL
      @300
      D=A
      @LCL
      M=D
      // set @ARG
      @400
      D=A
      @ARG
      M=D
      // set @THIS
      @3000
      D=A
      @THIS
      M=D
      // set @THAT
      @3010
      D=A
      @THAT
      M=D
      // call Sys.init
      #{generate_call(Command.new('call Sys.init', 'call', 'C_CALL', 'Sys.init', '0'))}
    ASM
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

  def generate_label(command)
    <<~ASM
      (#{@filename}.#{@current_function}$#{command.arg1})
    ASM
  end

  def generate_goto(command)
    increment_row(2)
    <<~ASM
      @#{@filename}.#{@current_function}$#{command.arg1}
      0;JMP
    ASM
  end

  def generate_if(command)
    increment_row(6)
    <<~ASM
      @SP
      M=M-1
      A=M
      D=M+1
      @#{@filename}.#{@current_function}$#{command.arg1}
      D;JEQ
    ASM
  end

  def generate_function(command)
    set_current_function(command.arg1)
    result = generate_function_label(command)
    command.arg2.to_i.times { result += push_constant(0) }
    result
  end

  def generate_function_label(command)
    <<~ASM
      (#{@filename}.#{command.arg1})
    ASM
  end

  def generate_call(command)
    increment_row(47)
    i = @function_calls_counter[command.arg1] += 1
    <<~ASM
      // push return-address
      @#{@filename}.#{command.arg1}$ret.#{i}
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
      // push LCL
      @LCL
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
      // push ARG
      @ARG
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
      // push THIS
      @THIS
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
      // push THAT
      @THAT
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
      // ARG = SP - n - 5
      @SP
      D=M
      @#{command.arg2.to_i + 5}
      D=D-A
      @ARG
      M=D
      // LCL = SP
      @SP
      D=M
      @LCL
      M=D
      // goto function
      @#{@filename}.#{command.arg1}
      0;JMP
      // (return-address)
      (#{@filename}.#{command.arg1}$ret.#{i})
    ASM
  end

  def generate_return(_command)
    increment_row(47)
    <<~ASM
      // endFRAME = LCL
      @LCL
      D=M
      @R13
      M=D
      // RETaddr = *(endFRAME - 5)
      @5
      A=D-A
      D=M
      @R14
      M=D
      // *ARG = pop()
      @SP
      M=M-1
      A=M
      D=M
      @ARG
      A=M
      M=D
      // SP = ARG + 1
      @ARG
      D=M+1
      @SP
      M=D
      // THAT = *(endFRAME - 1)
      @R13
      M=M-1
      A=M
      D=M
      @THAT
      M=D
      // THIS = *(endFRAME - 2)
      @R13
      M=M-1
      A=M
      D=M
      @THIS
      M=D
      // ARG = *(endFRAME - 3)
      @R13
      M=M-1
      A=M
      D=M
      @ARG
      M=D
      // LCL = *(endFRAME - 4)
      @R13
      M=M-1
      A=M
      D=M
      @LCL
      M=D
      // goto RETaddr
      @R14
      A=M
      0;JMP
    ASM
  end

  private

  def set_current_function(function_name)
    @current_function = function_name
  end

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
      @#{@filename}.#{value}
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
      @#{@filename}.#{value}
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
    increment_row(13)
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
