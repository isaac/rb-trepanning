# -*- coding: utf-8 -*-
# Copyright (C) 2010 Rocky Bernstein <rockyb@rubyforge.net>
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoProgram < Trepan::Subcommand
  unless defined?(HELP)
    HELP         = 'Information about debugged program and its environment'
    MIN_ABBREV   = 'pr'.size
    NAME         = File.basename(__FILE__, '.rb')
    NEED_STACK   = true
    PREFIX       = %w(info program)
  end

  def run(args)
    frame = @proc.frame
    m = 'Program stop event: %s' % @proc.event
    m += 
      if frame.iseq
        '; PC offset %d of instruction sequence: %s' % 
          [frame.pc_offset, frame.iseq.name]
      else
        '.'
      end
    msg m
    if 'return' == @proc.event 
      msg 'R=> %s' % @proc.frame.sp(1).inspect 
    elsif 'raise' == @proc.event
      msg @proc.core.hook_arg.inspect if @proc.core.hook_arg
    end

    if @proc.brkpt
      msg('It is stopped at %sbreakpoint %d.' %
          [@proc.brkpt.temp? ? 'temporary ' : '',
           @proc.brkpt.id])
    end
  end

end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  name = File.basename(__FILE__, '.rb')

  # FIXME: DRY the below code
  dbgr, cmd = MockDebugger::setup('info')
  subcommand = Trepan::Subcommand::InfoProgram.new(cmd)
  testcmdMgr = Trepan::Subcmd.new(subcommand)

  name = File.basename(__FILE__, '.rb')
  subcommand.run([name])
  subcommand.summary_help(name)
  puts
end
