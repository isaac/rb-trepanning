# -*- coding: utf-8 -*-
# Copyright (C) 2010 Rocky Bernstein <rockyb@rubyforge.net>
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoReturn < Trepan::Subcommand
  unless defined?(HELP)
    HELP         = 'Show the value about to be returned'
    MIN_ABBREV   = 'ret'.size # Note we have "info registers"
    NAME         = File.basename(__FILE__, '.rb')
    NEED_STACK   = true
    PREFIX       = %w(info return)
  end

  def run(args)
    event = @proc.event
    if %w(return c-return).member?(event)
      ret_val = Trepan::Frame.value_returned(@proc.frame, event)
      msg('Return value: %s' % ret_val.inspect)
    else
      errmsg('You need to be in a return event to do this. Event is %s' % 
             event)
    end
  end

end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  require_relative '../../subcmd'
  name = File.basename(__FILE__, '.rb')

  # FIXME: DRY the below code
  dbgr, cmd = MockDebugger::setup('info')
  subcommand = Trepan::Subcommand::InfoReturn.new(cmd)
  testcmdMgr = Trepan::Subcmd.new(subcommand)

  name = File.basename(__FILE__, '.rb')
  subcommand.summary_help(name)
end
