# Copyright (C) 2010 Rocky Bernstein <rockyb@rubyforge.net>
require_relative 'base/cmd'

class Trepan::Command::UnaliasCommand < Trepan::Command

  unless defined?(HELP)
    HELP = 
"unalias COMMAND

Remove alias for COMMAND

See also 'alias'.
"

    CATEGORY      = 'support'
    MIN_ARGS      = 1
    # MAX_ARGS      = 1  # Need at most this many
    NAME          = File.basename(__FILE__, '.rb')
    NEED_STACK    = true
    SHORT_HELP    = 'Remove an alias'
  end
  
  # Run command. 
  def run(args)
    args[1..-1].each do |arg|
      if @proc.aliases.member?(arg)
        @proc.aliases.delete(arg)
        msg "Alias for #{arg} removed."
      else
        msg "No alias found for #{arg}."
      end
    end
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  cmd.run %W(cmd.name s)
  cmd.run %W(cmd.name s)
  cmd.run %W(cmd.name foo bar n)
end
