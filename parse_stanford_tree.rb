class Stanford_Tree_Parse

  # We concentrate on the relationships between nouns, adjectives, pronouns and (ad)verbs.
  # Return a tree with all words notated as Sentence_No:Word_No and having dependency children.
  # Obviously this is open to a lot of development, and definite refactoring.
  # The key aim is to make this obsolete, the link to the Stanford Parser works consistently
  # but the typed dependencies are currently missing. These make up the context for returning to
  # WordNet for multi sense words (polysemy).

  require 'tree'
  require 'pos_tagger'

  attr_reader :pronouns, :nouns, :verbs, :adverbs, :adjectives, :other

  def initialize
    @pronouns = Array.new
    @nouns = Array.new
    @verbs = Array.new
    @adverbs = Array.new
    @adjectives = Array.new
    @other = Array.new

    # use symbols here?
    @adverb_tag =["RB", "RBR", "RBS"]
    @pronoun_tag = ["PRP", "POS", "P", "WP$", "PRP$"]
    @noun_tag = ["NNS", "NN", "NNS", "NNPS", "NNP"]
    @adjective_tag =["JJ", "JJR", "JJS"]
    @verb_tag =["VBG", "VBN", "VBD", "VBZ", "VB", "VBP"]
    @ignore_words=["NP","VP","ADVP","PP","S","SBAR","ADJP","ROOT","PRT","CONJP","WHNP","WHADVP"] # These are not included in the POS list
    @ignore_tags=["POS"] # Let's Ignore these things (e.g. Let's - 's is POS)


    @current_noun =""
    @current_verb=""
    @current_adverb=""
    @current_pronoun=""
    @current_adjective=""
    @tag_adj=String.new

  end

  def parse_penn_tree(str,filename,sentence_no)

    # str must be in Tree format from Stanford Parser !!
    # Create a tree for this sentence
    sentence_node = Tree::TreeNode.new("ROOT", filename)
    words=0
    count=0
    current_tag=""

    # Straight forward stripping out of unwanted data using string functions and RegEx
    str.gsub!(/[\d\.\d]/, '')
    #str.gsub(/\[\d+\.\d+\]/, '')
    str.gsub!(/"/, '')
    str.gsub!(/'/, '')
    str.gsub!(/[^0-9a-z' ']/i, '')
    #str.to_a.compact.reject { |s| s.nil? or s.empty? }


    p_t = str.split.to_a
    p_t.each{|t|
      count+=1

      # Access the POS Tags
      # We group tags by Adverb, Adjective, Noun, Verbs, Other.
      # These groups are made available (may be useful later on)
      # Taken from POS Tagging Guidelines for the Penn Treebank Project 2nd Printing.
      # Adverb : RB, RBR, RBS,
      # Pronoun :  PRP, POS, P, WP$, PRP$
      # Noun :  NNS, NN, NN, NNPS, NNP
      # Adjectives : JJ, JJR, JJS
      # Verbs : VBG, VBN, VBD, VBZ, VB, VBP
      # Other :

      if POS_Tagger.instance.have_tags?(t)
        current_tag=t
      else
        words+=1
        case
            when (@ignore_words.include?(t))
                  # Ignore these words
                  words-=1
            when (@ignore_tags.include?(current_tag))
                  # Ignore these Tags
                  words-=1
            when (@noun_tag.include?(current_tag))
                @nouns<<t
                add_details(t,current_tag,'noun',sentence_no,words,sentence_node)
                @current_noun=t
            when (@verb_tag.include?(current_tag))
                @verbs<<t
                add_details(t,current_tag,'verb',sentence_no,words,sentence_node)
                @current_verb=t
            when (@adverb_tag.include?(current_tag))
                @adverbs<<t
                add_details(t,current_tag,'adverb',sentence_no,words,sentence_node)
                @current_adverb=t
            when (@adjective_tag.include?(current_tag))
                add_details(t,current_tag,'adjective',sentence_no,words,sentence_node)
                @current_adjective=t
                @adjectives<<t
            when (@pronoun_tag.include?(current_tag))
                @pronouns<<t
                add_details(t,current_tag,'pronoun',sentence_no,words,sentence_node)
                @current_pronoun=t
            else
                add_details(t,current_tag,'other',sentence_no,words,sentence_node)
                @other<<t
        end
      end
    }
    #sentence_node.print_tree
    #puts sentence_node["1:2"]["Dep"].content
    #puts sentence_node["1:2"]["POS"].content
    sentence_node
  end

   def add_details word,tag,part,pos,word_no,sentence_node
      extra=String.new
      if word_no>1 then
        case part
          when 'noun'
            if !@current_adjective.empty?
                extra=word + ":" + @current_adjective
            elsif !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_pronoun.empty?
               extra=word + ":" + @current_pronoun
            elsif !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
          when 'pronoun'
            if !@current_adjective.empty?
               extra=word + ":" + @current_adjective
            elsif !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_pronoun.empty?
              extra=word + ":" + @current_pronoun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
          when 'adverb'
            if !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_pronoun.empty?
              extra=word + ":" + @current_pronoun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
           when 'adjective'
            if !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_pronoun.empty?
              extra=word + ":" + @current_pronoun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
          when 'verb'
            if !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_pronoun.empty?
              extra=word + ":" + @current_pronoun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
          when 'other'
            if !@current_verb.empty?
              extra=word + ":" + @current_verb
            elsif !@current_noun.empty?
              extra=word + ":" + @current_noun
            elsif !@current_pronoun.empty?
              extra=word + ":" + @current_pronoun
            elsif !@current_adverb.empty?
              extra=word + ":" + @current_adverb
            end
        end
      end

      sentence_node << Tree::TreeNode.new(pos.to_s + ":" + word_no.to_s, tag) << Tree::TreeNode.new("Dep", extra)
      #puts "#{word} #{pos.to_s + ":" + word_no.to_s} adding a POS #{part}"
      sentence_node[pos.to_s + ":" + word_no.to_s]<< Tree::TreeNode.new("POS", part)

   end

end