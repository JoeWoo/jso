# encoding: UTF-8
require './encode_helper'
include EncodeHelper



class Document

	attr_reader :name, :text, :terms, :most_common_term, :most_common_term_freq

	def initialize()
		@terms = Hash.new()
		@most_common_term = ""
		@most_common_term_freq = 0
	end

	def process(stopwords)

		stext=text()
		stext=segment_chinese_words(stext)
		# stext=toutf8(stext)
		stext.force_encoding("UTF-8")
		terms=Array.new
		terms = stext.scan(/([\u4e00-\u9fa5]+|[\w]+)/)

		normalizedterms = Array.new
		terms.each {|term| term.each{|ch| normalizedterms << ch.to_s.downcase} }

		normalizedterms = normalizedterms - stopwords
		puts "\t delete stop-words......."

		normalizedterms.each do |normalizedterm|
			@terms[normalizedterm] = DocumentTerm.new unless @terms.has_key?(normalizedterm)
			doc_term = @terms[normalizedterm]
			doc_term.term = normalizedterm
			doc_term.term_freq += 1
			if doc_term.term_freq > @most_common_term_freq
				@most_common_term = normalizedterm
				@most_common_term_freq = doc_term.term_freq
			end
		end

		#normalize frequency
		@terms.each_value do |term|
			term.normalized_freq = term.term_freq / Float(@most_common_term_freq)
		end

	end#end-func

end#end-class



class DocumentTerm

	attr_reader :term, :term_freq, :normalized_freq, :term_weight
	attr_writer :term, :term_freq, :normalized_freq, :term_weight

	def initialize()
		@term_freq = 0
		@normalized_freq = 0
		@term_weight = 0
	end

end


class DocumentFile < Document

	def initialize(filename)
		super()
		@filename = filename
	end

	def filename
		@filename
	end

	def readtext()
		str = IO.read(@filename)
		return str
	end

	def name
		@filename
	end

	def text
		readtext()
	end

end
