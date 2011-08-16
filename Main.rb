# Lets start off with opening a basic .txt file..

require 'gibsonfile'

include Ferret



puts "Processing a text file.."

f = GibsonFile.new("1.txt")
#f.parse_file
#f.stem
#f.remove_stop_words
#f.standford_parse
f.UIMA_test