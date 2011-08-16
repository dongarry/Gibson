# Detect stop words QUICKLY
# Uses a bloom filter instead of searching literally through a list of stopwords
# for > 3x speed increase
#
#    using bloom filter: 2.580000   0.030000   2.610000 (  2.698829)
#  using literal search: 7.850000   0.120000   7.970000 (  8.181684)


require 'bloominsimple'
require 'digest/sha1'
require 'pp'

# Create a simple bloom filter that uses a SHA1 hash (more effective than BloominSimple's default hashing)
b = BloominSimple.new(50000) do |word|
  Digest::SHA1.digest(word.downcase.strip).unpack("VVV")
end

# Add stopwords to the bloom filter!
stopwords = []
File.open('stopwords_en.txt').each { |a| b.add(a); stopwords << a.downcase.strip }

# Read in a whole dictionary of regular words
words = File.open('/usr/share/dict/words').read.split.collect{|a| a.downcase.strip }

# Define two ways to detect stopwords for comparison..
using_filter = lambda { |word| b.includes?(word) }
using_array = lambda { |word| stopwords.include?(word.downcase.strip) }
techniques = [using_filter, using_array]

# Run stopword comparisons with both techniques
t = techniques.collect { |l| words.collect { |a| l[a] } }

# See how effective the bloom filter has been compared to the literal search
if t[0] == t[1]
  puts "GOOD"
else
  words.zip(t[0],t[1]).each do |x|
    puts x.first if x[1] != x[2]
  end
end

# Now do speed benchmarks..
techniques.each { |l| puts Benchmark.measure { words.each { |a| l[a] } } }