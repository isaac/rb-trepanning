# -*- coding: utf-8 -*-
require_relative '../base/subcmd'

class Debugger::Subcommand::ShowDifferent < Debugger::ShowBoolSubcommand
  unless defined?(HELP)
    HELP = "Show status of 'set different'"
    MIN_ABBREV   = 'dif'.size
    NAME         = File.basename(__FILE__, '.rb')
  end

  def run(args)
    if 'nostack' == @proc.settings[:different]
      msg("different is nostack.")
    else
      super
    end
  end


end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  require_relative '../../subcmd'
  name = File.basename(__FILE__, '.rb')

  # FIXME: DRY the below code
  dbgr, cmd = MockDebugger::setup('exit')
  subcommand = Debugger::Subcommand::ShowDifferent.new(cmd)
  testcmdMgr = Debugger::Subcmd.new(subcommand)

  def subcommand.msg(message)
    puts message
  end
  def subcommand.msg_nocr(message)
    print message
  end
  def subcommand.errmsg(message)
    puts message
  end
  subcommand.run_show_bool
  name = File.basename(__FILE__, '.rb')
  subcommand.summary_help(name)
end
