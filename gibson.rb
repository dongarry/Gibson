class Gibson
require 'gibsondb'
require 'process_file'
require 'match'
require 'float.rb'
require 'uima'

include Ferret
include Match_Gibson

attr_accessor :dev_fg

  def initialize
    @sp = StanfordParser::LexicalizedParser.new()
    @dev_fg = 0
    @gib_rec={}
    clear_board

  end

  def clear_board
    @temp1=[]
    @temp2=[]
    @score_exp={} #Holds explanations for the scores

    @r1={}
    @r2={}
    @w1={}
    @w2={}

  end

  def sim file1, file2

    if !FileTest.exists?(file1) && !FileTest.exists?(file1)
        puts "Cannot locate that file!"
        exit
    end

    clear_board

    @f1 = Process_File.new(file1,@sp)
    @f1.check_and_load

    @f2 = Process_File.new(file2,@sp)
    @f2.check_and_load

    store_results 1
    store_results 2

    @f1.phase_2_WordNet
    @f2.phase_2_WordNet

    store_results 4

    summary_match # shallow hypernym match up.

    save_file @f1
    save_file @f2

  end


  def check_params param
    if @f1.nil? then
      puts "No files loaded."
      exit
    end
    if param.length==0 then
      return 0
    else
      if param.length==1
         return param[0]
      else
        puts "Invalid no of parameters! Please enter either 1 or 2 (File1/File2)"
        exit
      end
    end

  end

  def get_file_no no

    case no
      when 1
        return @f1
      when 2
        return @f2
      else
        return 0
    end
  end

  def results

  end

  def print_results

    if @r1.nil?
       puts "No results generated"
    else
       @r1.each{|k,v| puts v}
    end

    if @r2.nil?
       puts "No results generated"
    else
       @r2.each{|k,v| puts v}
    end

  end

  def print_tree *file
    g=check_params file
    f = get_file_no g

    if f == 0
      @f1.d_file.print_tree
      @f2.d_file.print_tree
    else
      dev_fg == 1 ? f.d_file.file_tree : f.d_file.print_tree
    end
  end

  def score *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f == 0
      ret = @f1.d_file.score.to_s + " | " + @f2.d_file.score.to_s
    else
      dev_fg == 1 ? f.d_file.score : ret = f.d_file.score.to_s
    end
  end

  def word_count *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f == 0
      ret = "#{@f1.d_file.filename} #{@f1.d_file.no_of_words}  | #{@f2.d_file.filename} #{@f2.d_file.no_of_words}"
    else
      dev_fg == 1 ? f.d_file.no_of_words : ret = f.d_file.no_of_words.to_s
    end
  end

  def sentence_count *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f == 0
      ret = "#{@f1.d_file.filename} #{@f1.d_file.no_of_sentences}  | #{@f2.d_file.filename} #{@f2.d_file.no_of_sentences}"
    else
      dev_fg == 1 ? f.d_file.no_of_sentences : ret = f.d_file.no_of_sentences.to_s
    end
  end

def explain *file
    g=check_params file

    if g>2 && g<1
      puts "Invalid parameter"
      exit
    end

    ret=""

    # Each holds the explanation for 2 scores.
    #numbers -> file1 : 0 + 2; file2 :1 + 3
    # When asked we present the latest - on dev fg, give all.

    if g == 0
      ret = "#{@f1.d_file.filename} : #{@score_exp[@score_exp.length -2].to_s} + \n + #{@f1.d_file.filename} : #{@score_exp[@score_exp.length -1].to_s}"
    else
      if dev_fg == 1 then
         @score_exp
      else
          g=1 ? ret = @score_exp[@score_exp.length - (2)].to_s : ret = @score_exp[@score_exp.length - (3)].to_s
          #ret = @score_exp[@score_exp.length - (3-g)].to_s
      end
    end
  end


  def summary *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f==0 then
      ret= "#{@f1.d_file.filename} #{@f1.d_file.hyper.join(" ")}\n"
      ret+= "#{@f2.d_file.filename} : #{@f2.d_file.hyper.join(" ")}"
    else
      dev_fg == 1 ? f.d_file.hyper : (ret= "#{f.d_file.filename} : #{f.d_file.hyper.join(" ")}")
    end
  end


  def print_tag file, tag

    f = get_file_no file
    ret=""

    if f==0 then
      puts "Error loading file. Please check parameters."
    else
      f.print_content tag
    end
  end

  def wordnet *file
    g=check_params file
    f = get_file_no g
    ret=""
    if f==0 then
      ret= "#{@f1.d_file.filename} #{@f1.d_file.wordnet.join(" ")}\n"
      ret+= "#{@f2.d_file.filename} : #{@f2.d_file.wordnet.join(" ")}"
    else
      dev_fg == 1 ? f.d_file.wordnet : (ret= "#{f.d_file.filename} : #{f.d_file.wordnet.join(" ")}")
    end
  end

  def verbs *file
    g=check_params file
    f = get_file_no g
    ret=""
    if f==0 then
      ret= "#{@f1.d_file.filename} #{@f1.d_file.verbs.join(" ")}\n"
      ret+= "#{@f2.d_file.filename} : #{@f2.d_file.verbs.join(" ")}"
    else
      dev_fg == 1 ? f.d_file.verbs : (ret= "#{f.d_file.filename} : #{f.d_file.verbs.join(" ")}")
    end
  end

  def nouns *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f==0 then
      ret= "#{@f1.d_file.filename} #{@f1.d_file.nouns.join(" ")}\n"
      ret+= "#{@f2.d_file.filename} : #{@f2.d_file.nouns.join(" ")}"
    else
      dev_fg == 1 ? f.d_file.nouns : (ret= "#{f.d_file.filename} : #{f.d_file.nouns.join(" ")}")
    end
  end

  def inverted *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f==0 then
      ret = "#{@f1.d_file.filename} : #{@f1.d_file.inverted_file.inspect}\n"
      ret += "#{@f2.d_file.filename} : #{@f2.d_file.inverted_file.inspect}\n"
    else
      dev_fg == 1 ? f.d_file.inverted_file : (ret= "#{f.d_file.filename} : #{f.d_file.inverted_file.inspect}")
    end
  end

  def show_wordNet_prog *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f==0 then
      ret = "#{@f1.d_file.filename} :"
      @f1.d_file.wordnet_rep.each {|k,v| ret+=v.to_s + ":"}
      ret += "#{@f2.d_file.filename} :"
      @f2.d_file.wordnet_rep.each {|k,v| ret+=v.to_s + ":"}
      ret
    else
      if dev_fg == 1 then
           f.d_file.wordnet_rep
      else
        ret = "#{f.d_file.filename} :"
        f.d_file.wordnet_rep.each {|k,v| ret+=v.to_s + ":"}
        ret
      end
    end
  end

  def notes *file
    g=check_params file
    f = get_file_no g
    ret=""

    if f==0 then
      puts "This is a garbage can of all that goes on, so please specify which file you would like."
    else
      dev_fg == 1 ? f.d_file.notes : (ret= "#{f.d_file.filename} : #{f.d_file.notes.join(";")}")
    end
  end

  def store_results phase

    # Do a basic boolean match and store results - Phase 1
    # Do a basic boolean match with WordNet and store results - Phase 2
    # Do a Ferret score and store results. - Phase 3
    # Repeat.

    fer=0

    case phase
      when 1
        @f1.d_file.inverted_file.each{|key,val|@temp1<<key}
        @f2.d_file.inverted_file.each{|key,val|@temp2<<key}
      else
        @temp1 = array_add(@temp1,@f1.d_file.wordnet)
        @temp2 = array_add(@temp2,@f2.d_file.wordnet)
        fer=1
    end
    res= lexical_match(@temp1,@temp2)

    if(res["1"]>0) then
      per_cent = 100.fdiv(@temp1.length.fdiv(res["1"]))
      per_cent_2 = 100.fdiv(@temp2.length.fdiv(res["1"]))
    else
      per_cent=0
      per_cent_2=0
    end

    @r1[phase]="Phase #{phase} #{per_cent.round_to(2)}% matching on #{@f1.d_file.filename} [Total Words: #{@temp1.length}]"
    @r2[phase]="Phase #{phase} #{per_cent_2.round_to(2)}% matching on #{@f2.d_file.filename} [Total Words: #{@temp2.length}]"

    if fer==1

      w5 = @f1.d_file.ferret_terms
      w5 << @f1.d_file.wordnet.uniq

      w6 = @f2.d_file.ferret_terms
      w6 << @f2.d_file.wordnet.uniq

      phase+=fer

      f_index = Ferret::I.new()
      f_index << {:file => "#{@f1.d_file.filename}", :content=> "#{w5.join(" ")}"}
      f_index.optimize

      f_2_index = Ferret::I.new()
      f_2_index << {:file => "#{@f2.d_file.filename}", :content=> "#{w6.join(" ")}"}
      f_2_index.optimize

      str1=ferret_score(f_index,w6)
      str2=ferret_score(f_2_index,w5)

      @r1[phase]="Phase #{phase} #{str1[0]}]"
      @score_exp[@score_exp.length]= str1[2]
      @f1.d_file.score=str1[1]
      @r2[phase]="Phase #{phase} #{str2[0]}"
      @score_exp[@score_exp.length]= str2[2]
      @f2.d_file.score=str2[1]

    end
  end

  def save_file  f
    # Keep successive similarity tests

    @gib_rec = Gibson_rec.new(:filename => f.d_file.filename,
        :no_of_words => f.d_file.no_of_words,
        :no_of_sentences=> f.d_file.no_of_sentences,
        :inverted_file =>f.d_file.no_of_sentences,
        :ferret_terms =>f.d_file.ferret_terms,
        :wordnet =>f.d_file.wordnet,
        :summary =>f.d_file.hyper,
        :notes =>f.d_file.notes,
        :verbs=>f.d_file.verbs,
        :nouns =>f.d_file.nouns,
        :wordnet_rep =>f.d_file.wordnet_rep
        )
  end

  def print_db
      dev_fg == 1 ? @gib_rec :  @gib_rec.inspect
  end


  def summary_match
    w1=[]
    w2=[]

    # Shallow Summary File lexical comparison
    @f1.d_file.hyper.each{|key,val|w1<<key}
    @f2.d_file.hyper.each{|key,val|w2<<key}

    res= lexical_match(w1,w2)

    if(res["1"]>0) then
      per_cent = 100.fdiv(w1.length.fdiv(res["1"]))
      per_cent_2 = 100.fdiv(w2.length.fdiv(res["1"]))
    else
      per_cent=0
      per_cent_2=0
    end

    @r1[10]="Final Summary #{per_cent.round_to(2)}% matching on #{@f1.d_file.filename} [Total Summary Words: #{@f1.d_file.hyper.length}]"
    @r2[10]="Final Summary #{per_cent_2.round_to(2)}% matching on #{@f2.d_file.filename} [Total Summary Words: #{@f2.d_file.hyper.length}]"


  end

end




