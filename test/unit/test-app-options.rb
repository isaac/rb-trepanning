#!/usr/bin/env ruby
require 'test/unit'
require 'stringio'
require 'tempfile'
require_relative '../../app/options'

# To have something to work with.
load 'tmpdir.rb'

class TestAppStringIO < Test::Unit::TestCase
  include Trepanning

  def setup
    @options = DEFAULT_CMDLINE_SETTINGS.clone
    @stderr  = StringIO.new
    @stdout  = StringIO.new
    @options = copy_default_options
    @opts = setup_options(@options, @stdout, @stderr)
  end

  def test_cd
    rest = @opts.parse(['--cd', Dir.tmpdir])
    assert_equal(Dir.tmpdir, @options[:chdir])
    assert_equal('', @stderr.string)
    assert_equal('', @stdout.string)

    setup
    tf    = Tempfile.new("delete-me")
    orig_cd = @options[:chdir]
    rest = @opts.parse(['--cd', tf.path])
    assert_equal(orig_cd, @options[:chdir])
    assert_not_equal('', @stderr.string)
    assert_equal('', @stdout.string)
    # FIXME: add test where directory isn't executable.
  end

  def test_binary_opts
    %w(nx).each do |name|
      setup
      o    = ["--#{name}"]
      rest = @opts.parse o
      assert_equal('', @stderr.string)
      assert_equal(true, @options[name.to_sym])
    end
  end

  def test_help_and_version_opts
    %w(help version).each do |name|
      setup
      o    = ["--#{name}"]
      rest = @opts.parse o
      assert_not_equal('', @stdout.string)
      assert_equal('', @stderr.string)
      assert_equal(true, @options[name.to_sym])
      other_sym = 'help' == name ? :version : :help
      assert_equal(false, @options.member?(other_sym))
    end
  end

end
