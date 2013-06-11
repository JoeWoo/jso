class Searcher

  def initialize(index)
    @index = index
  end

  def search(keywords)

    num_docs = @index.documents.length

    most_common_query_term = ""
    most_common_query_term_freq = 0

    # find the most_common_query_term values
    keywords.uniq.each do |keyword|
      freq_query_term =  0
      keywords.each {|k| freq_query_term += 1 if k == keyword }

      if freq_query_term > most_common_query_term_freq
        most_common_query_term = keyword
        most_common_query_term_freq = freq_query_term
      end
    end

    query_term_result = Array.new
    # calc the query vector
    keywords.uniq.each do |keyword|
      next unless @index.invertedIndex.has_key?(keyword)
      indexItem = @index.invertedIndex[keyword]
      freq_query_term =  0
      keywords.each {|k| freq_query_term += 1 if k == keyword }
      #ni = ni is # of documents in which the search term of interest appears
      ni = indexItem[1].length
      query_term_weight = (0.5 + ((0.5 * Float(freq_query_term)) / (most_common_query_term_freq * Float(freq_query_term)))) * Math.log(num_docs / Float(ni))
      docs_found = indexItem[1]
      query_term_result << [keyword, query_term_weight, docs_found]
    end

    #calc result
    # sim (d, q) = dj . q / |dj| x |q|
    query_result = Hash.new
    query_term_result.each  do |term_result|
      query_term_weight = term_result[1]
      docs_found  = term_result[2]
      docs_found.each do |d|
        doc = d[0]
        doc_weight = d[1]
        raking = doc_weight * query_term_weight
        query_result[doc.name] = [doc, raking]
      end
    end
    return query_result

  end#end-func

end#enc-class
