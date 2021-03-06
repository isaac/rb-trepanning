# -*- coding: utf-8 -*-
# Copyright (C) 2010 Rocky Bernstein <rockyb@rubyforge.net>
require_relative '../../base/subsubcmd'
require_relative 'helper'

class Trepan::Subcommand::InfoRegistersLfp < Trepan::SubSubcommand
  unless defined?(HELP)
    HELP         = 'Show the value of the VM local frame pointer (LFP).

When a local variable is defined for the first time, this stack
is pushed and the value for local variable is assigned to this stack entry.

See also "info register sp".'

    MIN_ABBREV   = 'lf'.size
    NAME         = File.basename(__FILE__, '.rb')
    NEED_STACK   = true
    PREFIX       = %w(info registers lfp)
  end

  include Registers
  def run(args)
    frame = @proc.frame
    if 'CFUNC' == frame.type
      msg "local_name not available for C function"
    else
      iseq = frame.iseq
      index = register_array_index(PREFIX[-1], args, iseq.local_size-1)
      msg("local_name(%d)=%s" % [index, iseq.local_name(index)]) if index
    end
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../../../mock'
  require_relative '../registers'
  cmd = MockDebugger::subsub_setup(Trepan::SubSubcommand::InfoRegisters,
                                   Trepan::SubSubcommand::InfoRegistersLfp,
                                   false)
  cmd.run([])
end
