# -*- coding: utf-8 -*-
require 'trace'
require 'columnize'
require_relative '../base/subcmd'

class Debugger::Subcommand::SetEvents < Debugger::Subcommand
  unless defined?(HELP)
    HELP         = "set events {event-name[,] ...}

Set trace events that the debugger will stop on

Valid event names come from the Trace module and include:
#{Columnize::columnize(Trace.const_get('EVENTS'), 80, ' ' * 4, true, true, ' ' * 2)}

Separate event names with space and an optional comma is also
allowable after an event name.

Examples:
   set events call return
   set ev call, c_call, return, c_return, c_return, insn
"
    MIN_ABBREV   = 'ev'.size
    NAME         = File.basename(__FILE__, '.rb')
    SHORT_HELP   = 'Set trace events we may stop on.'
  end

  def run(args)
    unless args.size <= 2
      events = args[2..-1]
      events.each {|event| event.chomp!(',')}
      bitmask, bad_events = Trace.events2bitmask(events)
      unless bad_events.empty?
        errmsg("Event names unrecognized/ignored: %s" % bad_events.join(', '))
      end
      @proc.core.step_events = bitmask
    end
    @proc.commands['show'].subcmds.subcmds[:events].run('events')
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  require_relative '../../subcmd'
  name = File.basename(__FILE__, '.rb')

  # FIXME: DRY the below code
  dbgr, cmd = MockDebugger::setup('set')
  subcommand = Debugger::Subcommand::SetEvents.new(cmd)
  testcmdMgr = Debugger::Subcmd.new(subcommand)

  name = File.basename(__FILE__, '.rb')
  subcommand.summary_help(name)
  puts
  subcommand.run([])
  [%w(call line foo), %w(insn, c_call, c_return,)].each do |events|
    subcommand.run(%w(set events) + events)
    puts 'bitmask: %09b, events: %s ' % [dbgr.core.step_events, events.inspect]
  end
end
