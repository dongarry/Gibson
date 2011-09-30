# With Credit to Peter Cooper (Bloominsimple example)

require 'benchmark'
require 'bitfield'

class HashField
  attr_reader :bitfield, :hasher

  def initialize(bitsize, &block)
    @bitfield = BitField.new(bitsize)
    @size = bitsize
    @hasher = block || lambda do |word|
      word = word.downcase.strip
      [h1 = word.sum, h2 = word.hash, h2 + h1 ** 3]
    end
  end

  def add(item)
    @hasher[item].each { |hi| @bitfield[hi % @size] = 1 }
  end

  def includes?(item)
    @hasher[item].each { |hi| return false unless @bitfield[hi % @size] == 1 } and true
  end
end