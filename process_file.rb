class Process_File
  require 'rubygems'

  require 'lingua/stemmer'
  require 'parse_stanford_tree'
  require 'hashfield'
  require 'digest/sha1'
  require 'ferret'
  require 'stanfordparser'
  require 'tree'
  require 'docfile'
  require 'wordnet_link'
  require 'uea-stemmer'

include Ferret

  attr_reader :filename,:d_file,:results
  attr_writer :inc

  def initialize(filename,sp)

    @inc  # Used to store all phases data, not on, will just store results.

    @d_file = DocFile.new(filename)
    @stfd_parser = sp
    @wordnet_link = Wordnet_link.new()
    @stemmer = Lingua::Stemmer.new(:language =>"en")
    @uea_stemmer = UEAStemmer.new

    @line=String.new()
    @name=String.new()
    @stop_words = []
    @results = {}

    @WordNoun = WordNet::Noun
    @WordVerb = WordNet::Verb
    @WordAdj = WordNet::Adjective
    @WordAdV = WordNet::Adverb

  end

  def check_and_load
    Linguistics::use( :en )

    if  !Linguistics::EN.has_link_parser? then
        puts "LinkParser Not Loaded! - Cannot check similarity"
        exit
    end
    if  !Linguistics::EN.has_wordnet? then
            puts "Wordnet Not Loaded! - Cannot check similarity"
            exit
    end

    load_stop_words

    lines=String.new()
    preproc = StanfordParser::DocumentPreprocessor.new()
    file = File.new(@d_file.filename, "r")
      while (line = file.gets)
          lines = lines + line.to_s
      end
      file.close

    sp_lines = preproc.getSentencesFromString(lines)
    sp_lines.each{|l|
        @d_file.no_of_sentences+=1
        s=l.join(' ')
        s.scan(/\w+/) {@d_file.no_of_words+=1}
        s.gsub!(/[^0-9a-z' ']/i, '') # Some punctuation getting through

        if !s.nil? then
                  process(s)
        end
    }

    @d_file.wordnet_rep["1"]  = @wordnet_link.count # Let's not how many WordNet links were made on the 1st pass.'

  end

  def process(line)

    # Term Tree information Stored
    # 1 Index - location of the term
    # 2 Term
    # 3 Stopword Fg
    # 4 Stem Term (if available)
    # 5 Hypernym Term
    # 7 WNL - all other WordNet terms..
    # 8 Typed Dependency - Context {This is now estimated locally -> Not available in Ruby that we can find!}

    stfd_t_p = Stanford_Tree_Parse.new() #Move this?

    stfd_str = @stfd_parser.apply(line).toString
    p_t = stfd_t_p.parse_penn_tree(stfd_str,@d_file.filename,@d_file.no_of_sentences)


    @d_file.verbs = @d_file.verbs | stfd_t_p.verbs
    @d_file.nouns = @d_file.nouns | stfd_t_p.nouns

    # At this point, stanford parser has returned a parse tree

    counter=0

    line.split(" ").each do |word|
      stop_word_ind=0
      counter+= 1
      index=@d_file.no_of_sentences.to_s + ":" + counter.to_s

      word.strip!
      word.downcase!

      @d_file.file_tree << Tree::TreeNode.new(index, word)
      if !p_t[index].nil?
        if !p_t[index]["Dep"].nil?
            @d_file.file_tree[index] << p_t[index]["Dep"]
        end
        if !p_t[index]["POS"].nil?
            @d_file.file_tree[index] << p_t[index]["POS"]
        else
          # + Log word not tagged
        end
      end

      if @stop_words.include?(word.downcase) then
        # + Log a stop word
        stop_word_ind=1
      else
        stem_word=stem(word).strip
        if !stem_word.nil?  then
            @d_file.file_tree[index]<< Tree::TreeNode.new("Stem", stem_word.downcase)
            @d_file.add_invert_term stem_word  # Add to inverted file

            # + Log stemmed word

            # Call WordNet to find the synonym / hypernyms / etc

            if !@d_file.file_tree[index]["POS"].nil? then

              w_type = get_wordnet_type @d_file.file_tree[index]["POS"].content

              @wordnet_link.find_word stem_word.downcase, w_type  #"WordNet::" + @d_file.file_tree[index]["POS"].content.capitalize

              if (@wordnet_link.w_update==0) then
                    # We do this to cater for incorrect stemming (will catch only a few)
                    if (!stem_word.eql?(uea_stem(word))) then
                      @wordnet_link.find_word uea_stem(word).downcase, w_type #"WordNet::" + @d_file.file_tree[index]["POS"].content.capitalize
                    end
              end

              if (@wordnet_link.w_update==1) then

                @d_file.file_tree[index]["POS"]<< Tree::TreeNode.new("WN", @wordnet_link.key)
                update_wordnet_link index

              elsif @wordnet_link.sense_count>0
                @d_file.file_tree[index]["POS"]<< Tree::TreeNode.new("WN", @wordnet_link.sense_count)
              end
            else
               # + Log No Part of Speech Tag
            end
          end
      end

      @d_file.file_tree[index]<< Tree::TreeNode.new("SW", stop_word_ind)

    end

  end

  def parse_file
    counter=1
    begin
      file = File.new(@filename, "r")
      while (line = file.gets)
            puts "#{counter} : #{line} "
            line.scan(/\w+/) {@no_of_words+=1}
            counter = counter + 1
      end
      puts "Word Count : #{count}"
      file.close

    rescue => err
      puts "Parsing Exception: #{err}"
      err
    end
  end

  def update_wordnet_link index

    @d_file.wordnet = @d_file.wordnet | @wordnet_link.get_all_levellinks
    @d_file.hyper = @d_file.hyper | @wordnet_link.hypernyms_list
    @d_file.notes<< @wordnet_link.notes

    if @wordnet_link.hypernyms_list.count>0
       if @d_file.file_tree[index]["POS"]["WN"]["Hyp"].nil? then
          @d_file.file_tree[index]["POS"]["WN"]<< Tree::TreeNode.new("Hyp", @wordnet_link.hypernyms_list.uniq.join(" "))
       else
          @d_file.file_tree[index]["POS"]["WN"]["Hyp"]=@wordnet_link.hypernyms_list.uniq.join(" ")
       end
    end

    if @wordnet_link.get_all_levellinks.count>0
       if @d_file.file_tree[index]["POS"]["WN"]["WNL"].nil? then
          @d_file.file_tree[index]["POS"]["WN"]<< Tree::TreeNode.new("WNL", @wordnet_link.get_all_levellinks.uniq.join(" "))
       else
          @d_file.file_tree[index]["POS"]["WN"]["WNL"]=@wordnet_link.get_all_levellinks.uniq.join(" ")
       end
    end
  end

  def get_wordnet_type pos

    w = String.new

    case pos
          when "verb"
              w = @WordVerb
          when "adjective"
              w = @WordAdj
          when "adverb"
              w = @WordAdV
          when "noun"
              w = @WordNoun
          else
              w = "Ignored"
        end
    w
  end

  def stem (word)
    stem = @stemmer.stem(word)
    #if stem.eql?(word) then
    #  @d_file.add_invert_term stem  # Add to inverted file
    #  nil
    #else
      stem
    #end
  end

  def uea_stem (word)
    stem = @uea_stemmer.stem(word)
    #if stem.eql?(word) then
    #  @d_file.add_invert_term stem  # Add to inverted file
    #  nil
    #else
      stem
    #end
  end

  def load_stop_words

      b = HashField.new(50000) do |word|
        Digest::SHA1.digest(word.downcase.strip).unpack("VVV")
      end

      File.open('stopwords_en.txt').each { |a| b.add(a); @stop_words << a.downcase.strip }

  end

  def phase_2_WordNet
        # We are keeping this separate as we want to view the impact (if any) this will have on the similarity
        # Traverse the tree and locate WN tags which have more than one sense.
        # The content is either the Synset key or the No. of Senses
        # Send the typed dependencies onto WordNet to check the context.

        @wordnet_link.count =0

        @d_file.file_tree.each_leaf{|node|
                if node.name== "WN" then
                        #puts "#{node.parent.parent.name} Dep : #{node.parent.parent["Dep"].nil?.to_s} :#{node.parent.parent["Stem"].content} : #{node.content.instance_of?(Fixnum)}"
                        if node.content.instance_of?(Fixnum) then
                          if !node.parent.parent["Dep"].nil? then
                              c= node.parent.parent["Dep"].content.to_s.strip.split(":")
                              type= get_wordnet_type node.parent.content

                              if !node.parent.parent["Stem"].nil? then
                                c[0] = node.parent.parent["Stem"].content
                              end

                              if !c.nil? and !c.empty? then
                                @wordnet_link.find_word_sense c[0],type, c[1]

                                if @wordnet_link.w_update==1 then
                                    @wordnet_link.wordnet_find_sense_by_key c[0],type
                                    if @wordnet_link.w_update==1
                                        update_wordnet_link node.parent.parent.name
                                        node.content=@wordnet_link.key

                                    end
                                end
                              end
                          end
                        end
                end
            }
        @d_file.wordnet_rep["2"]  = @wordnet_link.count # Let's not how many WordNet links were made on the 1st pass.'
  end

  def print_content tag
        found=0
        # todo - There is a much better looping way to do this, this has got a little out of control (see has_parentage method)
        # Check on the first level.
        @d_file.file_tree.each{|node|
                if node.name== tag then
                        found=1
                        if !node.parent.parent.parent.nil? then
                          puts "Great GrandParent : #{node.parent.parent.parent.name} - Content : #{node.parent.parent.parent.content}"
                        end

                        if !node.parent.parent.nil? then
                          puts "GrandParent : #{node.parent.parent.name} - Content : #{node.parent.parent.content}"
                        end

                        if !node.parent.nil? then
                              puts "Parent : #{node.parent.name} - Content : #{node.parent.content}"
                              puts "#{tag} node content : #{node.content}"

                        end
                        if node.has_children?
                            node.each_leaf{|child|
                              puts "#{tag} children: #{child.name} : #{child.content}"

                              if child.has_children?
                                node.each_leaf{|chil|
                                  puts "#{tag} children: #{chil.name} : #{chil.content}"
                                  }
                              end
                            }
                        end
                end
            }

        if found==0 then
          @d_file.file_tree.each_leaf{|node|
                  if node.name== tag then
                          found=1
                          if !node.parent.parent.nil? then
                            puts "GrandParent : #{node.parent.parent.name} - Content : #{node.parent.parent.content}"
                          end

                          if !node.parent.nil? then
                                puts "Parent : #{node.parent.name} - Content : #{node.parent.content}"
                                puts "#{tag} node content : #{node.content}"

                          end
                  end
                }
        end
  end


  def remove_stop_words
    # Consider a quicker solution for removing stop words.
    stop_words = []
    newwords=[]

    b = HashField.new(50000) do |word|
      Digest::SHA1.digest(word.downcase.strip).unpack("VVV")
    end

    File.open('stopwords_en.txt').each { |a| b.add(a); stop_words << a.downcase.strip }

    words = File.open(@filename).read.split.collect{|a| a.downcase.strip }

   counter=1
    begin
      file = File.new(@filename, "r")
      while (line = file.gets)
          new_words = line.scan(/\w+/)
          key_words = new_words.select { |word| !stop_words.include?(word.downcase.strip) }
          puts key_words.join(' ')
          counter = counter + 1
      end
      file.close

    rescue => err
      puts "Exception: #{err}"
      err
    end
  end

end