# Lets start off with opening a basic .txt file..

require 'gibsonfile'
require 'process_file'
require 'match'
require 'float.rb'
require 'uima'
include Ferret
include Match_Gibson


puts "Processing a text file.."

#f = GibsonFile.new("Sample1.txt")
#f.test_stemming
#f.parse_file
#f.remove_stop_words
#f.stem
#f.standford_parse
#f.standford_parse_2
#f.standford_parse_3
#f.wordnet_parse
#f.wordnet_parse_9
#f.parse_file_uima
#f=UIMA.new()
#f.UIMA_test("Don Garry met Mark Keane for a review of project development ASAP")

# We only want to load this stanford parser file once
sp = StanfordParser::LexicalizedParser.new()

f1 = Gibson.new("Sample1.txt",sp)
f1.check_and_load
f2 = Gibson.new("Sample2.txt",sp)
f2.check_and_load

puts " ********************************************** "
w1=[]
f1.d_file.inverted_file.each{|key,val|w1<<key}
w2=[]
f2.d_file.inverted_file.each{|key,val|w2<<key}

res= lexical_match(w1,w2)
puts "Phase 1 Basic Lexical Matched on #{res["1"]} terms"
puts res["2"].flatten

puts "#{f1.d_file.no_of_words} : #{f2.d_file.no_of_words}"

if(res["1"]>0) then
  per_cent = 100.fdiv(f1.d_file.no_of_words/res["1"])
  per_cent_2 = 100.fdiv(f2.d_file.no_of_words/res["1"])
else
  per_cent=0
  per_cent_2=0
end

puts "#{per_cent.round_to(2)}% matching on #{f1.d_file.filename}"
puts "#{per_cent_2.round_to(2)}% matching on #{f2.d_file.filename}"

puts " ********************************************** "
w3 = array_add(w1,f1.d_file.wordnet)
puts w3
w4 = array_add(w2,f2.d_file.wordnet)

#puts f2.d_file.wordnet.uniq
res= lexical_match(w3,w4)
puts "Phase 2 Basic Lexical Matched on #{res["1"]} terms"
puts res["2"].flatten

puts "#{f1.d_file.no_of_words} : #{f2.d_file.no_of_words}"

if(res["1"]>0) then
  per_cent = 100.fdiv(f1.d_file.no_of_words/res["1"])
  per_cent_2 = 100.fdiv(f2.d_file.no_of_words/res["1"])
else
  per_cent=0
  per_cent_2=0
end

puts "#{per_cent.round_to(2)}% matching on #{f1.d_file.filename}"
puts "#{per_cent_2.round_to(2)}% matching on #{f2.d_file.filename}"


puts " ******************** Ferret Score ***************************** "

w5 = f1.d_file.ferret_terms
w5 << f1.d_file.wordnet.uniq

w6 = f2.d_file.ferret_terms
w6 << f2.d_file.wordnet.uniq


puts "Ferret:" + w5.join(" ")
puts "Ferret:" + w6.join(" ")

f_index = Ferret::I.new()
f_index << {:file => "#{f1.d_file.filename}", :content=> "#{w5.join(" ")}"}

f_2_index = Ferret::I.new()
f_2_index << {:file => "#{f2.d_file.filename}", :content=> "#{w6.join(" ")}"}

ferret_score(f_index,w6)
ferret_score(f_2_index,w5)

#f1.d_file.file_tree.print_tree

puts " ********************************************** Phase 2 **************"
f1.phase_2_WordNet
f2.phase_2_WordNet

w7 = array_add(w1,f1.d_file.wordnet)
w8 = array_add(w2,f2.d_file.wordnet)

res= lexical_match(w7,w8)
puts "Phase 2 Basic Lexical Matched on #{res["1"]} terms"
puts res["2"].flatten

puts "#{f1.d_file.no_of_words} : #{f2.d_file.no_of_words}"

if(res["1"]>0) then
  per_cent = 100.fdiv(f1.d_file.no_of_words/res["1"])
  per_cent_2 = 100.fdiv(f2.d_file.no_of_words/res["1"])
else
  per_cent=0
  per_cent_2=0
end

puts "#{per_cent.round_to(2)}% matching on #{f1.d_file.filename}"
puts "#{per_cent_2.round_to(2)}% matching on #{f2.d_file.filename}"

puts " ********************************************** Phase 3 **************"

puts "File 1 Summary"
puts f1.d_file.hyper
puts "File 2 Summary"
puts f2.d_file.hyper

#print f2.d_file.print_tree
pp f1.d_file.verbs
