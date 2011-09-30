class Wordnet_link

      # Sept 11 - Note there is a new Ruby Wordnet gem version due which handles lookups much easier.
      # See : https://github.com/ged/ruby-wordnet/blob/convert-to-sequel/examples/distance.rb

      # Use the Wordnet Distance method to see if words are related but is still useful?
      # Warning - Ruby generates a warning from this wordnet_distance : warning: Object#type is deprecated;
      # use Object#class. This is not related to this Wordnet call but to Ruby.

=begin
      # Taken from Stackoverflow,com : http://stackoverflow.com/questions/831380/class-vs-type-in-ruby
      The key difference is that Object#type is deprecated. From the RDoc for Object#type:
      Deprecated synonym for Object#class.
      Here's why you should use Object#class:
      Returns the class of obj, now preferred over Object#type, as an object‘s type in Ruby is only loosely tied
      to that object‘s class. This method must always be called with an explicit receiver,
      as class is also a reserved word in Ruby.
      In reality, you probably want to use Object#respond_to? instead of checking for the
      class of an object in most cases.
=end

require 'rubygems'
require 'wordnet'
require 'bdb'
require 'linguistics'
require 'linkparser'

  attr_accessor :w_update,:notes, :hypernyms_list, :sense_count, :key, :count,:sen

  def initialize
      @word=String.new()
      @word=String.new()
      @key=String.new()  # Returns Synsets unique id, made up of its offset and syntactic category concatenated together with a ’%’ symbol.
      @sense_count=0
      @sen=0
      @lex = WordNet::Lexicon::new

      clear_board

      @w_update=0
      @count=0

  end

      def wordnet_distance type, word_1, word1_sense, word_2, word2_sense
        x = @lex.lookup_synsets( word1, WordNet::Noun,word1_sense)
        y = @lex.lookup_synsets( word2, WordNet::Noun,word2_sense)
        c.distance(type,d)
        # Can return nil if nothing found.
      end

      def clear_board
        @hypernyms_list=[]
        @synonyms_list=[]
        @holonyms_list=[]
        @entailments_list=[]
        @antonyms_list=[]
        @notes={}
      end

      def find_word p_word, p_type

        # Phase 1 : Check Wordnet for instance of the word
        # If there is only one sense - then return the store details
        @w_update=0
        @sense_count=0
        @key=""

        synset=@lex.lookup_synsets( p_word, p_type)
        if !synset.nil?
          @sense_count=synset.count
          if synset.count==1

              @count+=1

              # There is only one sense, add these details
              # we only go one step up for Hypernyms
              @w_update=1
              upload_synset synset[0], p_word
          else
            #log
          end
        end
      end

    def upload_synset synset, p_word
           clear_board
           num=1

           @key = synset.key

              synset.hypernyms.each{|a| @notes["hyper"].nil? ? @notes["hyper"] = " #{p_word} => #{a.words[0]} " : @notes["hyper"] +=" #{p_word} => #{a.words[0]} "
                                                              @hypernyms_list << a.words[0].strip
                                                              num+=1}

              synset.traverse(:holonyms){|syn,step| if step >0 then @notes["holo_p_word_#{step}->"]=" #{p_word} => #{syn.words[0]} "
                                                              @holonyms_list << syn.words[0].strip
                                                              end}

              synset.traverse(:entailment){|syn,step| if step >0 then @notes["enta_p_word_#{step}->"]=" #{p_word} => #{syn.words[0]} "
                                                              @entailments_list << syn.words[0].strip
                                                              end}

              num=1
              synset.antonyms.each{|a| @notes["anto_p_word_#{num}"]=" #{p_word} => #{a.words[0]} "
                                                              @antonyms_list << a.words[0].strip
                                                              num+=1
                                          }

              if !synset.words.nil? then
                  synset.words.each{|w| if !w.strip.eql?(p_word.strip) then
                                                                # Don't add the same word again.
                                                                @notes["synon:#{synset.words.index(w)+1}"]=" #{p_word} => #{w} "
                                                                @synonyms_list << w #synset.words[0].strip

                                                          end}

              end
    end

    def find_word_sense p_word, p_type, p_context

        # Phase 2 : Check Wordnet to locate the sense of the word based on context
        @w_update=0
        @sense_count=0
        @key=""
        num=0

        if !p_word.nil? and !p_context.nil?
          synset=@lex.lookup_synsets( p_word, p_type)

          if !synset.nil?
            @sense_count=synset.count
            if synset.count>1

              synset.each{|b| #if b.gloss =~/p_context/ then @key=b.key()
                              num+=1
                              g=b.gloss.to_s
                              g.gsub!(/"/, '')
                              if !g.match(p_context).nil? then
                                    @w_update=1
                                    @count+=1
                                    @key=b.key()
                                    return @key # Leave at the 1st one - WordNet Synset are ordered by relevance.
                              end

                           }

            end
          end
        end
    end

    def get_all_links
        @hypernyms_list + @holonyms_list + @synonyms_list + @entailments_list + @antonyms_list
    end

    def get_all_levellinks
        @holonyms_list + @synonyms_list + @entailments_list + @antonyms_list
    end

    def wordnet_find_sense_by_key word,type

        # Use the uique key from Synset to identify which sense you want.
        # Note : lookup_synsets_by_key( *keys ) method is not working!
        # see Wordnet test case
        # key


        a = @lex.lookup_synsets( word, type)
        a.each{|b| if b.key() == @key then
                     upload_synset b, word
                     break
                   end}
    end


end