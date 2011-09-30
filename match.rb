module Match_Gibson

  include Ferret

  def lexical_match terms1, terms2

    terms_matched=Array.new()
    matched=0
    matched_result={}

    terms1.each{|t|
                if terms2.include?(t) then
                  matched+=1
                  terms_matched<<t
                end
            }

    matched_result["1"]=matched
    matched_result["2"]=terms_matched

    matched_result

  end

  def array_add main, new

    new.each{|t|
                if !main.include?(t) then
                  main<<t
                end
            }
    main

  end

  def ferret_score f_index, query
      str=[]
      query = 'content:('  + "#{query.join(" ")}" + ')'

      f_index.search_each(query) do |id, score|
          str << "Query #{f_index[id][:file]} matched with a score of #{score}"
          str << score
          str << "Explain: #{f_index.explain(query,id)}"
        end

      str
  end

end
