# -*- coding: utf-8 -*-
require_relative %w(base cmd)
require_relative %w(.. eval)
class Debugger::Command::PrintCommand < Debugger::Command

  unless defined?(HELP)
    HELP = 
      "print EXPRESSION

Print the value of the EXPRESSION. Variables accessible are those of the
environment of the selected stack frame, plus globals. 

If the length output string large, the first part of the value is
shown and ... indicates it has been truncated."

    # ALIASES       = %w(p)
    CATEGORY      = 'data'
    NAME          = File.basename(__FILE__, '.rb')
    SHORT_HELP    = 'Print expression'
  end
  
  def run(args)
    msg @proc.debug_eval(args[1..-1].join(' '), @proc.settings[:maxstring])
  end
end
        
if __FILE__ == $0
  require_relative %w(.. mock)
  name = File.basename(__FILE__, '.rb')
  dbgr, cmd = MockDebugger::setup(name)
  cmd.run([name])
  cmd.run([name, '1+2'])
  cmdproc = dbgr.core.processor
  cmds = dbgr.core.processor.commands
end