class DocFile
  require 'rubygems'
  require 'tree'

  attr_accessor :filename, :no_of_words, :no_of_sentences, :file_tree,:inverted_file,:wordnet,:hyper,:notes,:verbs,
                :ferret_terms, :nouns, :score, :wordnet_rep

  def initialize(filename)

    @filename=filename
    @no_of_words=0
    @no_of_sentences=0
    @line=String.new()
    @score=0.0

    @file_tree = Tree::TreeNode.new("ROOT", filename)
    @inverted_file = {} # Contains term Frequency
    @ferret_terms = Array.new  # These are non unique
    @wordnet = Array.new()

    @hyper = Array.new()
    @notes = Array.new()
    @verbs = Array.new()
    @nouns = Array.new()

    @wordnet_rep = {} # Lets note changes from WordNet - for Audit purposes!

  end

  def print_tree
    @file_tree.print_tree
  end

  def add_invert_term value
    if @inverted_file[value].nil?
        @inverted_file[value]=1
    else
       @inverted_file[value]+=1
    end
    @ferret_terms<<value
  end

  def print_inverted_file
      @inverted_file.each {|t,f| puts "#{t}:#{f}"}
  end

end