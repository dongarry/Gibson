class GibsonFile
  require 'rubygems'
  require 'lingua/stemmer'
  require 'bloominsimple'
  require 'digest/sha1'
  require 'pp'
  require 'ferret'
  require 'find'
  #require 'stanfordparser'
  require 'bdb'
  require 'linguistics'
  require 'linkparser'
  require 'wordnet'

include Ferret
  attr_reader :filename

  def initialize(filename)
    @filename=filename
  end

  def process

  end

  def stem
    s = Lingua::Stemmer.new(:language =>"en")
    File.open(@filename).each do |line|
      line.split(" ").each do |num|
        puts num + ":" + s.stem("#{num}")
      end
    end
  end

  def parse_file
    counter=1
    begin
      file = File.new(@filename, "r")
      while (line = file.gets)
            puts "#{counter}: #{line}"
            counter = counter + 1
      end
      file.close
    rescue => err
      puts "Exception: #{err}"
      err
    end
  end

  def remove_stop_words

    # Consider the bloominsimple example for a quicker solution for removing stop words.


    stop_words = []
    newwords=[]

    b = BloominSimple.new(50000) do |word|
      Digest::SHA1.digest(word.downcase.strip).unpack("VVV")
    end

    File.open('stopwords_en.txt').each { |a| b.add(a); stop_words << a.downcase.strip }

    words = File.open(@filename).read.split.collect{|a| a.downcase.strip }

    #newwords = words.scan(/\w+/)
    #key_words = newwords.select { |word| !stop_words.include?(word) }

    #puts key_words.join(' ')

   counter=1
    begin
      file = File.new(@filename, "r")
      #file = File.open(@filename).read.split.collect{|a| a.downcase.strip }
      while (line = file.gets)
          new_words = line.scan(/\w+/)
          key_words = new_words.select { |word| !stop_words.include?(word.downcase.strip) }
          puts key_words.join(' ')
          #puts "#{counter}: #{line}"
          counter = counter + 1
      end
      file.close
    rescue => err
      puts "Exception: #{err}"
      err
    end
  end

  def standford_parse
    preproc = StanfordParser::DocumentPreprocessor.new
    x = preproc.getSentencesFromString("This is a sentence.  So is this.")
    puts x.inspect
  end

  def wordnet_parse
    Linguistics::use( :en )
    #puts "get the leftmost ball from the rack".en.sentence.verb
    #puts "instrument".en.synset(:verb)
    # Fetch just the words for the other kinds of "instruments"
    puts "instrument".en.hyponyms.collect {|synset| synset.words}.flatten
  end

  def UIMA_test
    require 'rjb'
    #puts Rjb::import('java.util.UUID').randomUUID().toString()

    # Let's call UIMA using the rjb Bridge..'
    #XMLInputSource in = new XMLInputSource("/home/don/Documents/apache-uima/examples/descriptors/analysis_engine/NamesAndPersonTitles_TAE.xml");
    #x_in = Rjb::import('XMLInputSource').new

    jars =Dir.glob("/home/don/Documents/apache-uima/lib/*.jar")
    Rjb::load(jars.join(':'), jvmargs=[])

    mfile="/home/don/Documents/apache-uima/examples/descriptors/analysis_engine/NamesAndPersonTitles_TAE.xml"
    x_in = Rjb::import('org.apache.uima.util.XMLInputSource')



    #instance_x_in = x_in.new_with_sig("org.apache.uima.util.XMLInputSource;",mfile)
    instance_x_in = x_in.new(mfile)

    puts instance_x_in

    #ResourceSpecifier specifier = UIMAFramework.getXMLParser().parseResourceSpecifier(in);
    #specifier = Rjb::import('org.apache.uima.resource.ResourceSpecifier')
    uima_framework = Rjb::import('org.apache.uima.UIMAFramework')
    specifier_in = uima_framework.getXMLParser().parseResourceSpecifier(instance_x_in)

    #AnalysisEngine engine = UIMAFramework.produceAnalysisEngine(specifier);
    #analysis_engine = Rjb::import('org.apache.uima.analysis_engine.AnalysisEngine')
    analysis_engine_in = uima_framework.produceAnalysisEngine(specifier_in)

    #JCas jcas = engine.newJCas();
		#jcas.setDocumentLanguage("en");
		#jcas.setDocumentText("This is a test for Don Garry of the name and person titles annotation for Jim Rock on the for AIG Corp : 21st Jan 2001, on 17:59am.");
		#engine.process(jcas);

    #analysis_engine = Rjb::import('org.apache.uima.jcas.JCas')
    #analysis_engine_in = analysis_engine
    jcas = analysis_engine_in.newJCas()
    jcas.setDocumentLanguage("en")
    jcas.setDocumentText("This is a test for Don Garry of the name and person titles annotation for Jim Rock on the for AIG Corp : 21st Jan 2001, on 17:59am.")
    analysis_engine_in.process(jcas)

    #@jString =  Rjb::import('java.lang.String')
    #str = @jString.new_with_sig('Ljava.lang.String;', "abcde").to_s
    #puts str

    index=Rjb::import('org.apache.uima.cas.FSIndex')
    annotation = Rjb::import('org.apache.uima.jcas.tcas.Annotation')
    myIndex = jcas.getAnnotationIndex()
    #FSIndex<Annotation> index = jcas.getAnnotationIndex();

    m_it = myIndex.iterator()
    while m_it.hasNext() do
      my_annotation=m_it.next
      if my_annotation.getType().getName().include?("com.mycompany")
        features = my_annotation.getType().getFeatures().toArray()
        Array new_things = features
        j_a_List = features
        #puts features
      end
      puts my_annotation.getCoveredText()
      puts features

      #j_List= Rjb::import('java.util.List')
      #j_a_List= Rjb::import('java.util.ArrayList')
      #j_it= Rjb::import('java.util.Iterator')
      #j_a_List_im=j_a_List.new


      myfeature=Rjb::import('org.apache.uima.cas.Feature')
      #feature_in =  myfeature.new

        #for ele in features
        #  myfeature=ele
        #  puts myfeature.to_s
        #end

        #features.each {|f|
        #  feature_in=f
        #  #puts f
        #  puts feature_in.getShortName()
        #  puts my_annotation.getStringValue(feature_in)
        #}
        #for feature in features do
        #    puts feature.getShortName
        #end

    end


    puts "RJB END"

  end

  def UIMA_Print_Results


  end

end

class GibsonTextFile < GibsonFile

  def remove_stop_words


  end

end