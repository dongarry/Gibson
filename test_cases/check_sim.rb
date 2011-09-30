require "test/unit"
require 'gibson'

class TestSim < Test::Unit::TestCase
  @a=Gibson.new()
  @a.sim("test1.txt","test2.txt")

  def check_count
    assert_equal(1, @a.sentence_count(1))
    assert_equal(1, @a.word_count(1) )
  end

  def check_name
    assert_equal("test1.txt", @a.filename(1))
    assert_equal(1, @a.word_count(1) )
  end
end

=begin
require 'gibson.rb'

a=Gibson.new()
a.sim("sports1.txt","health1.txt")
a.sim("sports2.txt","health2.txt")
=end


