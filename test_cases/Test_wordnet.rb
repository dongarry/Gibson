require "simpleNumber"
require "test/unit"
require 'wordnet'
require 'bdb'
require 'linguistics'
require 'linkparser'   

class TestWordNet < Test::Unit::TestCase
 
  def test_simple
    Linguistics::use( :en )
    assert_true(Linguistics::EN.has_link_parser?)
    assert_true(Linguistics::EN.has_wordnet?)

    dict = LinkParser::Dictionary.new( :screen_width => 100 )
    sent = dict.parse( "Hello there" )
    puts sent	
    assert_equal(4, SimpleNumber.new(2).add(2) )
    assert_equal(6, SimpleNumber.new(2).multiply(3) )
  end
 
end
