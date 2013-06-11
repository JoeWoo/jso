class Index

  attr_reader :invertedIndex, :documents
  attr_writer :invertedIndex, :documents

  def initialize()
    @invertedIndex = Hash.new
    @documents = Hash.new
  end

  def total_number_of_terms
    invertedIndex.length
  end

  def total_number_of_documents
    documents.length
  end

end
