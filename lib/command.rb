# frozen_string_literal: true

class Command
  attr_reader :vm_command, :command, :type, :arg1, :arg2

  def initialize(vm_command, command, type, arg1, arg2)
    @vm_command = vm_command
    @command = command
    @arg1 = arg1
    @arg2 = arg2
    @type = type
  end
end
