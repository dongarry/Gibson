class UIMA

require 'rubygems'

  def UIMA_test(line)
      require 'rjb'

      # Let's call UIMA using the rjb Bridge..'

      #jars =Dir.glob("/home/don/Documents/apache-uima/lib/*.jar")
      #jars =Dir.glob("\home\don\Documents\apache-uima\lib\*.jar")
      #jars =Dir.glob("/\home/\don/\Documents/\apache-uima/\lib/\*.jar")
      #Rjb::load(jars.join(':'), jvmargs=[])

      dir="/home/don/Documents/apache-uima/lib/"
      Dir.chdir(dir)
      jars = Dir.glob("*.jar").map{|item| dir + item}
      puts jars.to_s
      Rjb::load jars.join(File::PATH_SEPARATOR)

      puts "processing..3"

      mfile="/home/don/Documents/apache-uima/examples/descriptors/analysis_engine/NamesAndPersonTitles_TAE.xml"
      #mfile="\home\don\Documents\apache-uima\examples\descriptors\analysis_engine\NamesAndPersonTitles_TAE.xml"
      #mfile="/\home/\don/\Documents/\apache-uima/\examples/\descriptors/\analysis_engine/\NamesAndPersonTitles_TAE.xml"
      x_in = Rjb::import('org.apache.uima.util.XMLInputSource')
      puts "processing..2"

      instance_x_in = x_in.new(mfile)

      uima_framework = Rjb::import('org.apache.uima.UIMAFramework')
      specifier_in = uima_framework.getXMLParser().parseResourceSpecifier(instance_x_in)

      analysis_engine_in = uima_framework.produceAnalysisEngine(specifier_in)

      jcas = analysis_engine_in.newJCas()
      jcas.setDocumentLanguage("en")
      #jcas.setDocumentText("This is a test for Don Garry of the name and person titles annotation for Jim Rock on the for AIG Corp : 21st Jan 2001, on 17:59am.")
      jcas.setDocumentText(line)
      analysis_engine_in.process(jcas)

      index=Rjb::import('org.apache.uima.cas.FSIndex')
      annotation = Rjb::import('org.apache.uima.jcas.tcas.Annotation')
      myIndex = jcas.getAnnotationIndex()
      #FSIndex<Annotation> index = jcas.getAnnotationIndex();

      puts "processing.."
      m_it = myIndex.iterator()
      while m_it.hasNext() do
        my_annotation=m_it.next
        if my_annotation.getType().getName().include?("com.mycompany")
          features = my_annotation.getType().getFeatures().toArray()
          Array new_things = features
          j_a_List = features
        end
        puts my_annotation.getType().getShortName() + ":" + my_annotation.getCoveredText()
     end


      puts "RJB END"

    end
end
